# Copyright © 2011-2017 MUSC Foundation for Research Development~
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

class ParticipantReport < Report

  VALIDATES_PRESENCE_OF = [:title, :participant_id].freeze
  VALIDATES_NUMERICALITY_OF = [].freeze

  require 'csv'

  def generate(document)
    document.update_attributes(content_type: 'text/csv', original_filename: "#{@params[:title]}.csv")
    participant = Participant.find(@params[:participant_id])
    protocol    = participant.protocol

    CSV.open(document.path, "wb") do |csv|
      csv << ["Protocol:", participant.protocol.short_title_with_sparc_id]
      csv << ["Protocol PI Name:", protocol.pi ? "#{protocol.pi.full_name} (#{protocol.pi.email})" : nil]
      csv << ["Participant Name:", participant.full_name]
      csv << ["Participant ID:", participant.label]
      csv << [""]
      csv << [""]

      header_row = ["Visit Schedule", ""]
      label_row = ["Procedure Name", "Service Cost"]

      appointments = participant.appointments.order(:position)

      appointments.each do |appointment|
        header_row << (appointment.completed_date ? appointment.completed_date.strftime("%D") : "")
        label_row << appointment.name
      end

      label_row << ""
      label_row << "Totals"
      csv << header_row
      csv << label_row

      csv << [""]

      procedure_row_generator(participant.procedures.where.not(visit_id: nil), appointments, csv)

      csv << [""]
      csv << [""]
      csv << ["Unscheduled Procedures"]
      csv << [""]

      procedure_row_generator(participant.procedures.where(visit_id: nil), appointments, csv)

      csv << [""]
      csv << [""]
      csv << [""]
      total_row = ["Total/Visit", ""]
      grand_total = 0

      appointments.each do |appointment|
        appointment_total = appointment.procedures.where.not(completed_date: nil).to_a.sum(&:service_cost)
        total_row << display_cost(appointment_total)
        grand_total += appointment_total
      end

      total_row << ""
      total_row << display_cost(grand_total)
      csv << total_row
    end
  end

  def procedure_row_generator(procedures, appointments, csv)
    procedures.to_a.group_by(&:service).each do |service, procedures_by_service|
      procedures_by_service.group_by(&:cost).each do |service_cost, procedures_by_cost|
        total_for_row = 0
        procedure_row = [service.name]
        procedure_row << display_cost(service_cost)
        appointments.each do |appointment|
          cost = procedures_by_cost.select{|procedure| procedure.appointment_id == appointment.id && procedure.complete?}.sum(&:service_cost)
          procedure_row << display_cost(cost)
          total_for_row += cost
        end
        procedure_row << ""
        procedure_row << display_cost(total_for_row)
        csv << procedure_row
      end
    end
  end
end
