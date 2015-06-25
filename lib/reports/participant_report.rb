class ParticipantReport < Report

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

      appointments = participant.appointments

      appointments.each do |appointment|
        header_row << appointment.completed_date ? appointment.completed_date.strftime("%D") : ""
        label_row << appointment.name
      end
      csv << header_row
      csv << label_row

      csv << [""]

      participant.procedures.to_a.group_by(&:service).each do |service, procedures_by_service|
        procedures_by_service.group_by(&:service_cost).each do |service_cost, procedures|
          procedure_row = [service.name]
          procedure_row << display_cost(service_cost)
          appointments.each do |appointment|
            procedure_row << display_cost(procedures.select{|procedure| procedure.appointment_id == appointment.id && procedure.complete?}.sum(&:service_cost))
          end
          csv << procedure_row
        end
      end
    end
  end
end
