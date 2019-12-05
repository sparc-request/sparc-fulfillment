# Copyright © 2011-2019 MUSC Foundation for Research Development~P
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

  # report columns
  if HAS_RMID
    REPORT_COLUMNS = ["Protocol ID (SRID)",
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
                      ]
  else
    REPORT_COLUMNS = ["Protocol ID (SRID)",
                      "Patient Last Name",
                      "Patient First Name",
                      "Visit Name",
                      "Custom Visit",
                      "Start Date",
                      "Completed Date",
                      "Visit Duration (minutes)",
                      "Type of Visit",
                      "Visit Indications",
                      ]
  end

  def generate(document)
    document.update_attributes(content_type: 'text/csv', original_filename: "#{@params[:title]}.csv")

    from_start_date = @params[:start_date].empty? ? Appointment.order(start_date: :asc).detect{|appointment| appointment.start_date }.start_date : Time.strptime(@params[:start_date], "%m/%d/%Y").utc
    to_start_date   = @params[:end_date].empty? ? Appointment.order(start_date: :desc).first.start_date : Time.strptime(@params[:end_date], "%m/%d/%Y").tomorrow.utc - 1.second

    CSV.open(document.path, "wb") do |csv|
      csv << ["Visit Start Date From #{@params[:start_date]} To #{@params[:end_date]}"]
      csv << [""]
      csv << REPORT_COLUMNS

      result_set  = Appointment.all.joins(procedures: [{ protocols_participant: :participant}]).
                    where(
                      Appointment.arel_table[:start_date].gt(from_start_date).and(
                        Appointment.arel_table[:start_date].lt(to_start_date)).and(
                        Procedure.arel_table[:status].not_eq("unstarted"))).distinct.
                    pluck(
                      ProtocolsParticipant.arel_table[:protocol_id], Participant.arel_table[:last_name], Participant.arel_table[:first_name],
                      Appointment.arel_table[:name], Appointment.arel_table[:start_date], Appointment.arel_table[:completed_date],
                      Appointment.arel_table[:visit_group_id], Appointment.arel_table[:type], Appointment.arel_table[:id],
                      Procedure.arel_table[:status], Procedure.arel_table[:sparc_core_name], Appointment.arel_table[:contents], Participant.arel_table[:id])

      sorted_result_set = sort_result_set(result_set)

      sorted_result_set.each do |appointment|
        if HAS_RMID
          csv << [appointment[0], appointment[13], appointment[1], appointment[2], appointment[3], is_custom_visit(appointment),
                  get_date(appointment, true), get_date(appointment, false), get_duration(appointment),
                  get_content(appointment), get_statuses(appointment[8])]
        else
          csv << [appointment[0], appointment[1], appointment[2], appointment[3], is_custom_visit(appointment),
                  get_date(appointment, true), get_date(appointment, false), get_duration(appointment),
                  get_content(appointment), get_statuses(appointment[8])]
        end
      end
    end
  end

  def sort_result_set(result_set)
    sorted_set = filter_result_set(result_set)
    
    sorted_set.sort{ |x, y| x <=> y || 1 }
  end

  def is_custom_visit(appointment)
    appointment[6].nil? ? "Yes" : "No"
  end

  def get_duration(appointment)
    appointment[5].nil? ? "N/A" : ((appointment[5] - appointment[4])/60).round
  end

  def get_date(appointment, start)
    if start == true
      return appointment[4].nil? ? "N/A" : format_date(appointment[4])
    else
      return appointment[5].nil? ? "N/A" : format_date(appointment[5])
    end
  end

  def get_content(appointment)
    appointment[11].nil? ? nil : appointment[11]
  end

  def get_statuses(appointment_id)
    appt_status = AppointmentStatus.find_by(appointment_id: appointment_id)
    (appt_status.blank? ? "" : appt_status.status)
  end

  def filter_result_set(result_set)
    used_appointments = []
    filtered_set = []
    result_set.each do |appointment|
      protocol = Protocol.find(appointment[0])
      comparison_array = [appointment[0], appointment[1], appointment[2], appointment[3], get_duration(appointment), appointment[6], appointment[12]]
      if !used_appointments.include?(comparison_array)
        used_appointments << comparison_array
        srid = protocol.srid
        appointment[0] = srid
        appointment << protocol.research_master_id
        filtered_set << appointment
      end
    end

    filtered_set
  end
end

