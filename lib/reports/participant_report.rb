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
