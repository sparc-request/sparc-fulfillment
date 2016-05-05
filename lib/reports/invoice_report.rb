class InvoiceReport < Report

  VALIDATES_PRESENCE_OF = [:title, :start_date, :end_date].freeze
  VALIDATES_NUMERICALITY_OF = [].freeze

  require 'csv'

  # A protocol with subsidy, format protocol_id column with an 's'
  # A protocol without subsidy, format protcol_id column without an 's'
  def format_protocol_id_column(protocol)
    protocol.subsidies.any? ? protocol.sparc_id.to_s + 's' : protocol.sparc_id
  end

  def generate(document)
    #We want to filter from 00:00:00 in the local time zone,
    #then convert to UTC to match database times
    @start_date = Time.strptime(@params[:start_date], "%m-%d-%Y").utc
    #We want to filter from 11:59:59 in the local time zone,
    #then convert to UTC to match database times
    @end_date   = Time.strptime(@params[:end_date], "%m-%d-%Y").tomorrow.utc - 1.second

    document.update_attributes(content_type: 'text/csv', original_filename: "#{@params[:title]}.csv")

    CSV.open(document.path, "wb") do |csv|
      csv << ["From", format_date(Time.strptime(@params[:start_date], "%m-%d-%Y")), "To", format_date(Time.strptime(@params[:end_date], "%m-%d-%Y"))]
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
            "Short Title",
            "Primary PI",
            "Service",
            "Fulfillment Date",
            "Performed By",
            "Fulfillment Components",
            "Contact",
            "Account #",
            "Quantity Completed",
            "Quantity Type",
            "Research Rate",
            "Total Cost"
          ]
          csv << [""]

          protocol.fulfillments.fulfilled_in_date_range(@start_date, @end_date).joins(:line_item).order("line_items.quantity_type, fulfilled_at").each do |fulfillment|
            csv << [
              format_protocol_id_column(protocol),
              protocol.sparc_protocol.short_title,
              protocol.pi ? protocol.pi.full_name : nil,
              fulfillment.service_name,
              format_date(fulfillment.fulfilled_at),
              fulfillment.performer.full_name,
              fulfillment.components.map(&:component).join(','),
              fulfillment.line_item.contact_name,
              fulfillment.line_item.account_number,
              fulfillment.quantity,
              fulfillment.line_item.quantity_type,
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
            "Short Title",
            "Primary PI",
            "Patient Name",
            "Patient ID",
            "Visit Name",
            "Visit Date",
            "Service",
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
                format_protocol_id_column(protocol),
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
        csv << [""]
        csv << ["", "", "", "", "", "", "", "", "", "", "Study Level and Per Patient Total:", display_cost(total)]
        csv << [""]
        csv << [""]
      end
    end
  end
end
