class InvoiceReport < Report

  VALIDATES_PRESENCE_OF = [:title, :start_date, :end_date].freeze
  VALIDATES_NUMERICALITY_OF = [].freeze

  require 'csv'

  def generate(document)
    #We want to filter from 00:00:00 in the local time zone,
    #then convert to UTC to match database times
    @start_date = Time.strptime(@params[:start_date], "%m-%d-%Y").utc
    #We want to filter from 11:59:59 in the local time zone,
    #then convert to UTC to match database times
    @end_date   = Time.strptime(@params[:end_date], "%m-%d-%Y").tomorrow.utc - 1.second

    document.update_attributes(content_type: 'text/csv', original_filename: "#{@params[:title]}.csv")

    CSV.open(document.path, "wb") do |csv|
      csv << ["From", format_date(@start_date), "To", format_date(@end_date)]
      csv << [""]

      if @params[:protocol_ids].present?
        protocols = Protocol.find(@params[:protocol_ids])
      else
        protocols = Identity.find(@params[:identity_id]).protocols
      end

      protocols.each do |protocol|
        total = 0

        if protocol.fulfillments.fulfilled_in_date_range(@start_date, @end_date).any?
          csv << ["Study Level Charges:"]
          csv << [
            "Protocol ID",
            "Protocol Short Title",
            "Primary PI",
            "Fulfillment Date",
            "Service(s) Completed",
            "Quantity Completed",
            "Account #",
            "Contact",
            "",
            "Research Rate",
            "Total Cost"
          ]
          csv << [""]

          protocol.fulfillments.fulfilled_in_date_range(@start_date, @end_date).each do |fulfillment|
            csv << [
              protocol.sparc_id,
              protocol.sparc_protocol.short_title,
              protocol.pi ? protocol.pi.full_name : nil,
              format_date(fulfillment.fulfilled_at),
              fulfillment.service_name,
              fulfillment.quantity,
              fulfillment.line_item.account_number,
              fulfillment.line_item.contact_name,
              "",
              display_cost(fulfillment.service_cost),
              display_cost(fulfillment.total_cost)
            ]

            total += fulfillment.total_cost
          end
        end

        if protocol.procedures.completed_r_in_date_range(@start_date, @end_date).any?
          csv << [""]
          csv << [""]

          csv << ["Procedures/Per-Patient-Per-Visit:"]
          csv << [
            "Protocol ID",
            "Protocol Short Title",
            "Primary PI",
            "Patient Name",
            "Patient ID",
            "Visit Name",
            "Visit Date",
            "Service(s) Completed",
            "Service Completion Date",
            "Quantity Completed",
            "Research Rate",
            "Total Cost"
          ]
          csv << [""]
          protocol.procedures.completed_r_in_date_range(@start_date, @end_date).group_by(&:appointment).each do |appointment, appointment_procedures|
            participant = appointment.participant

            appointment_procedures.group_by(&:service_name).each do |service_name, service_procedures|
              procedure = service_procedures.first

              csv << [
                protocol.sparc_id,
                protocol.sparc_protocol.short_title,
                protocol.pi ? protocol.pi.full_name : nil,
                participant.full_name,
                participant.label,
                appointment.name,
                format_date(appointment.start_date),
                procedure.service_name,
                format_date(procedure.completed_date),
                service_procedures.size,
                display_cost(procedure.service_cost),
                display_cost(service_procedures.size * procedure.service_cost.to_f)
              ]
              total += service_procedures.size * procedure.service_cost.to_f
            end
          end
        end
        if total > 0
          csv << [""]
          csv << ["", "", "", "", "", "", "", "", "Study Level and Per Patient Total:", display_cost(total)]
          csv << [""]
          csv << [""]
        end
      end
    end
  end
end
