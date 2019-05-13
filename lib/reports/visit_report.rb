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

  # report columns
  if ENV.fetch('RMID_URL'){nil}
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
                      Procedure.arel_table[:status], Procedure.arel_table[:sparc_core_name], Appointment.arel_table[:contents])

      get_protocol_rmid(result_set) if ENV.fetch('RMID_URL'){nil}
      get_protocol_srids(result_set)

      result_set.group_by { |protocol, last_name, first_name, visit_name| [protocol, last_name, first_name, visit_name] }.
        map      { |grouping, appointments| get_appointment_info(grouping) <<
                                            is_custom_visit(appointments) <<
                                            get_date(appointments[0][4]) <<
                                            get_date(appointments[0][5]) <<
                                            get_duration(appointments[0]) <<
                                            get_content(appointments[0]) <<
                                            get_statuses(appointments[0][8])}.
        sort     { |x, y| x <=> y || 1 }.
        each     { |line|    csv << line }
    end
  end

  def get_appointment_info(grouping)
    if ENV.fetch('RMID_URL'){nil}
      [ @srid[grouping[0]] ] + [ @rmid[grouping[0]] ] + grouping[1..3]
    else
      [ @srid[grouping[0]] ] + grouping[1..3]
    end
  end

  def is_custom_visit(appointments)
    appointments.detect{ |appointment| appointment[6].nil? } ? "Yes" : "No"
  end

  def get_duration(appointment)
    appointment[5].nil? ? "N/A" : ((appointment[5] - appointment[4])/60).round
  end

  def get_date(appointment)
    appointment.nil? ? "N/A" : format_date(appointment)
  end

  def get_protocol_srids(result_set)
    protocol_ids = result_set.map(&:first).uniq
    # SRID's indexed by protocol id
    @srid = Hash[ Protocol.includes(:sub_service_request).
                  select(:id, :sparc_id, :sub_service_request_id). # cols necessary for SRID
                  where(id: protocol_ids).
                  map { |protocol| [protocol.id, protocol.srid] }]
  end

  def get_protocol_rmid(result_set)
    protocol_ids = result_set.map(&:first).uniq
    # RMID's indexed by protocol id
    @rmid = Hash[ Protocol.
                  select(:id, :sparc_id). # cols necessary for RMID
                  where(id: protocol_ids).
                  map { |protocol| [protocol.id, protocol.research_master_id] }]
  end

  def get_content(appointments)
    appointments[11].nil? ? nil : appointments[11]
  end

  def get_statuses(appointment_id)
    appt_status = AppointmentStatus.find_by(appointment_id: appointment_id)
    (appt_status.blank? ? "" : appt_status.status)
  end
end

