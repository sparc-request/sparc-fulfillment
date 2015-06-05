class BillingReportJob < ActiveJob::Base
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper
  queue_as :default
  require 'csv'

  def perform(report_id, start_date, end_date, protocol_ids)
    CSV.open("tmp/admin_billing_report.csv", "wb") do |csv|
      csv << ["From", format_date(start_date.to_date), "To", format_date(end_date.to_date)]
      csv << [""]

      if protocol_ids
        protocols = Protocol.find(protocol_ids)
      else
        protocols = Protocol.all
      end

      csv << ["Study Level Charges:"]
      csv << ["Protocol ID", "Primary PI", "Fulfillment Date", "Service(s) Completed", "Quantity Completed", "Research Rate", "Total Cost"]
      csv << [""]

      protocols.each do |protocol|
        protocol.fulfillments.fulfilled_in_date_range(start_date, end_date).each do |fulfillment|
          csv << [protocol.sparc_id, protocol.pi ? protocol.pi.full_name : nil, format_date(fulfillment.fulfilled_at), fulfillment.service_name, fulfillment.quantity, display_cost(fulfillment.service_cost), display_cost(fulfillment.total_cost)]
        end
      end

      csv << [""]
      csv << [""]
      csv << [""]
      csv << [""]

      csv << ["Procedures/Per-Patient-Per-Visit:"]
      csv << ["Protocol ID", "Primary PI", "Patient Name", "Patient ID", "Visit Name", "Visit Date", "Service(s) Completed", "Quantity Completed", "Research Rate", "Total Cost"]
      csv << [""]

      protocols.each do |protocol|
        protocol.procedures.completed_r_in_date_range(start_date, end_date).to_a.group_by(&:service).each do |group, procedures|
          procedure = procedures.first
          participant = procedure.participant
          appointment = procedure.appointment
          csv << [protocol.sparc_id, protocol.pi ? protocol.pi.full_name : nil, participant.full_name, participant.label, appointment.name, format_date(appointment.start_date), procedure.service_name, procedures.size, (procedure.service_cost.to_f / 100), (procedures.size * procedure.service_cost.to_f) / 100]
        end
      end
    end

    report = Report.find(report_id)

    if report.create_document(doc: File.open("tmp/admin_billing_report.csv"))
      report.status = "Completed"
      report.save
    end
    FayeJob.enqueue(report)
  end
end

#protocol.procedures.to_a.select{|procedure| procedure.completed_date && (start_date..end_date).cover?(procedure.completed_date)}.delete_if{|procedure| procedure.billing_type != "research_billing_qty"}
