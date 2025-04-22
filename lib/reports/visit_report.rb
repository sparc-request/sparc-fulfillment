# Copyright © 2011-2023 MUSC Foundation for Research Development~P
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

require 'csv'

class VisitReport < Report
  VALIDATES_PRESENCE_OF     = [:title].freeze
  VALIDATES_NUMERICALITY_OF = [].freeze

  HAS_RMID = ENV.fetch('RMID_URL'){nil}

  def generate(document)
    include_core_procudures = @params[:core_procedures_option].present? ? true : false
    permitted_protocols = @params[:permissions]

    document.update_attributes(content_type: 'text/csv', original_filename: "#{@params[:title]}.csv")

    from_start_date = @params[:start_date].empty? ? Appointment.order(start_date: :asc).detect{|appointment| appointment.start_date }.start_date : Time.strptime(@params[:start_date], "%m/%d/%Y").utc
    to_start_date   = @params[:end_date].empty? ? Appointment.order(start_date: :desc).first.start_date : Time.strptime(@params[:end_date], "%m/%d/%Y").tomorrow.utc - 1.second

    CSV.open(document.path, "wb") do |csv|
      csv << ["Visit Start Date From #{@params[:start_date]} To #{@params[:end_date]}"]
      csv << [""]
      csv << report_columns(include_core_procudures)

      result_set = ProcedureGroup.joins(appointment: { procedures: { protocols_participant: [:participant, :protocol] }})
        .where(Protocol.arel_table[:id].in(permitted_protocols)) #filters results according to current user's allowable protocols
        .where(Appointment.arel_table[:start_date].gteq(from_start_date)
        .and(Appointment.arel_table[:start_date].lteq(to_start_date))
        .and(Procedure.arel_table[:status].not_eq("unstarted")))
        .pluck(
        ProtocolsParticipant.arel_table[:protocol_id], #0
        Participant.arel_table[:last_name], #1
        Participant.arel_table[:first_name], #2
        Appointment.arel_table[:name], #3
        Appointment.arel_table[:start_date], #4
        Appointment.arel_table[:completed_date], #5
        Appointment.arel_table[:visit_group_id], #6
        Appointment.arel_table[:type], #7
        Appointment.arel_table[:id], #8
        Procedure.arel_table[:status], #9 (-6)
        ProcedureGroup.arel_table[:sparc_core_id], #10 (-5)
        Appointment.arel_table[:contents], #11 (-4)
        Participant.arel_table[:id], #12 (-3)
        ProcedureGroup.arel_table[:start_time], #13 (-2)
        ProcedureGroup.arel_table[:end_time]) #14 (-1)

      sorted_result_set = sort_result_set(result_set, include_core_procudures)

      sorted_result_set.each do |procedure_group_row|

        if HAS_RMID
          if include_core_procudures == true
            csv << [
              procedure_group_row[0], procedure_group_row[-1],
              procedure_group_row[1], procedure_group_row[2],
              procedure_group_row[3],
              is_custom_visit(procedure_group_row),
              get_date(procedure_group_row, true),
              get_date(procedure_group_row, false),
              get_duration(procedure_group_row),
              get_content(procedure_group_row),
              get_statuses(procedure_group_row[8]),
              get_core_name(procedure_group_row[10]),
              format_time(procedure_group_row[-3]),
              format_time(procedure_group_row[-2])
            ]
          else
            csv << [
              procedure_group_row[0], procedure_group_row[-1],
              procedure_group_row[1], procedure_group_row[2],
              procedure_group_row[3],
              is_custom_visit(procedure_group_row),
              get_date(procedure_group_row, true),
              get_date(procedure_group_row, false),
              get_duration(procedure_group_row),
              get_content(procedure_group_row),
              get_statuses(procedure_group_row[8])
            ]
          end
        else
          if include_core_procudures == true
            csv << [
              procedure_group_row[0], procedure_group_row[1],
              procedure_group_row[2], procedure_group_row[3],
              is_custom_visit(procedure_group_row),
              get_date(procedure_group_row, true),
              get_date(procedure_group_row, false),
              get_duration(procedure_group_row),
              get_content(procedure_group_row),
              get_statuses(procedure_group_row[8]),
              get_core_name(procedure_group_row[10]),
              format_time(procedure_group_row[-2]),
              format_time(procedure_group_row[-1])
            ]
          else
            csv << [
              procedure_group_row[0], procedure_group_row[1],
              procedure_group_row[2], procedure_group_row[3],
              is_custom_visit(procedure_group_row),
              get_date(procedure_group_row, true),
              get_date(procedure_group_row, false),
              get_duration(procedure_group_row),
              get_content(procedure_group_row),
              get_statuses(procedure_group_row[8])
            ]
          end
        end
      end
    end
  end

  def sort_result_set(result_set, core_procedures_option)
    sorted_set = filter_result_set(result_set, core_procedures_option)

    sorted_set.sort{ |x, y| x <=> y || 1 }
  end

  def is_custom_visit(procedure_group_row)
    procedure_group_row[6].nil? ? "Yes" : "No"
  end

  def get_core_name(core_id)
    Organization.name_for_id(core_id)
  end

  def get_duration(procedure_group_row)
    procedure_group_row[5].nil? ? "N/A" : ((procedure_group_row[5] - procedure_group_row[4])/60).round
  end

  def get_date(procedure_group_row, start)
    if start == true
      return procedure_group_row[4].nil? ? "N/A" : format_date(procedure_group_row[4])
    else
      return procedure_group_row[5].nil? ? "N/A" : format_date(procedure_group_row[5])
    end
  end

  def get_content(procedure_group_row)
    procedure_group_row[11].nil? ? nil : procedure_group_row[11]
  end

  def get_statuses(appointment_id)
    appt_status = AppointmentStatus.find_by(appointment_id: appointment_id)
    (appt_status.blank? ? "" : appt_status.status)
  end

  def filter_result_set(result_set, core_procedures_option)
    used_appointments = []
    filtered_set = []

    result_set.each do |procedure_group_row|
      appointment_id = procedure_group_row[8]
      core_id = procedure_group_row[10]
      appointment_record = Appointment.find(appointment_id)
      group_procedures = appointment_record.procedures.select { |p| p.sparc_core_id == core_id }
      next if Procedure.filter_unavailable_services(group_procedures).empty?
      if core_procedures_option == true
        protocol = Protocol.find(procedure_group_row[0])
        comparison_array = [
          procedure_group_row[0], #protocol_id
          procedure_group_row[1], #last_name
          procedure_group_row[2], #first_name
          procedure_group_row[3], #visit_name
          get_duration(procedure_group_row), #visit_duration
          procedure_group_row[6], #visit_group_id
          procedure_group_row[12],#participant_id
          procedure_group_row[10],#core_name
          procedure_group_row[13],#start_time
          procedure_group_row[14] #end_time
        ]

        if !used_appointments.include?(comparison_array)
          used_appointments << comparison_array
          srid = protocol.srid
          procedure_group_row[0] = srid
          procedure_group_row << protocol.research_master_id
          filtered_set << procedure_group_row
        end
      else
        protocol = Protocol.find(procedure_group_row[0])
        comparison_array = [
          procedure_group_row[0], #protocol_id
          procedure_group_row[1], #last_name
          procedure_group_row[2], #first_name
          procedure_group_row[3], #visit_name
          get_duration(procedure_group_row), #visit_duration
          procedure_group_row[6], #visit_group_id
          procedure_group_row[12] #participant_id
        ]

        if !used_appointments.include?(comparison_array)
          used_appointments << comparison_array
          srid = protocol.srid
          procedure_group_row[0] = srid
          procedure_group_row << protocol.research_master_id
          filtered_set << procedure_group_row
        end
      end
    end

    filtered_set
  end

  def report_columns(core_procedures_option)
    if HAS_RMID
      if core_procedures_option == true
        columns = ["Protocol ID (SRID)",
                          "RMID",
                          "Patient Last Name",
                          "Patient First Name",
                          "Visit Name",
                          "Custom Visit",
                          "Start Date",
                          "Completed Date",
                          "Visit Duration (minutes)",
                          "Type of Visit",
                          "Visit Indications",
                          "Core",
                          "Core Procedures Start Time",
                          "Core Procedures End Time"
                          ]
      else
        columns = ["Protocol ID (SRID)",
                          "RMID",
                          "Patient Last Name",
                          "Patient First Name",
                          "Visit Name",
                          "Custom Visit",
                          "Start Date",
                          "Completed Date",
                          "Visit Duration (minutes)",
                          "Type of Visit",
                          "Visit Indications"
                          ]
      end
    else
      if core_procedures_option == true
        columns = ["Protocol ID (SRID)",
                          "Patient Last Name",
                          "Patient First Name",
                          "Visit Name",
                          "Custom Visit",
                          "Start Date",
                          "Completed Date",
                          "Visit Duration (minutes)",
                          "Type of Visit",
                          "Visit Indications",
                          "Core",
                          "Core Procedures Start Time",
                          "Core Procedures End Time"
                          ]
      else
        columns = ["Protocol ID (SRID)",
                        "Patient Last Name",
                        "Patient First Name",
                        "Visit Name",
                        "Custom Visit",
                        "Start Date",
                        "Completed Date",
                        "Visit Duration (minutes)",
                        "Type of Visit",
                        "Visit Indications"
                        ]
      end
    end

    return columns
  end
end
