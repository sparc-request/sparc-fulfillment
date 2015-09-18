class BillingReport < Report

  VALIDATES_PRESENCE_OF = [:title, :start_date, :end_date].freeze
  VALIDATES_NUMERICALITY_OF = [].freeze

  require 'csv'

  def generate(document)
    @start_date = Time.strptime(@params[:start_date], "%m-%d-%Y")
    @end_date   = Time.strptime(@params[:end_date], "%m-%d-%Y")

    document.update_attributes(content_type: 'text/csv', original_filename: "#{@params[:title]}.csv")

    CSV.open(document.path, "wb") do |csv|
      csv << ["From", format_date(@start_date), "To", format_date(@end_date)]
      csv << [""]

      if @params[:protocol_ids].present?
        protocols = Protocol.find(@params[:protocol_ids])
      else
        protocols = Protocol.all
      end

      csv << ["Study Level Charges:"]
      csv << [
        "Protocol ID",
        "Primary PI",
        "Fulfillment Date",
        "Service(s) Completed",
        "Quantity Completed",
        "Research Rate",
        "Total Cost"
      ]
      csv << [""]

      protocols.each do |protocol|
        protocol.fulfillments.fulfilled_in_date_range(@start_date, @end_date).each do |fulfillment|
          csv << [
            protocol.sparc_id,
            protocol.pi ? protocol.pi.full_name : nil,
            format_date(fulfillment.fulfilled_at),
            fulfillment.service_name,
            fulfillment.quantity,
            display_cost(fulfillment.service_cost),
            display_cost(fulfillment.total_cost)
          ]
        end
      end

      csv << [""]
      csv << [""]
      csv << [""]
      csv << [""]

      csv << ["Procedures/Per-Patient-Per-Visit:"]
      csv << [
        "Protocol ID",
        "Primary PI",
        "Patient Name",
        "Patient ID",
        "Visit Name",
        "Visit Date",
        "Service(s) Completed",
        "Quantity Completed",
        "Research Rate",
        "Total Cost"
      ]
      csv << [""]

      protocols.each do |protocol|
        total = 0
        protocol.procedures.completed_r_in_date_range(@start_date, @end_date).to_a.group_by(&:service).each do |service, procedures|
          procedure = procedures.first
          participant = procedure.participant
          appointment = procedure.appointment
          csv << [
            protocol.sparc_id,
            protocol.pi ? protocol.pi.full_name : nil,
            participant.full_name,
            participant.label,
            appointment.name,
            format_date(appointment.start_date),
            procedure.service_name,
            procedures.size,
            display_cost(procedure.service_cost),
            display_cost(procedures.size * procedure.service_cost.to_f)
          ]
          total += procedures.size * procedure.service_cost.to_f
        end
        if total > 0
          csv << ["", "", "", "", "", "", "", "", "Total:", display_cost(total)]
          csv << [""]
          csv << [""]
        end
      end
    end
  end
end
