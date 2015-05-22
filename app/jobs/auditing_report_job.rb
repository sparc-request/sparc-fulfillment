class AuditingReportJob < ActiveJob::Base
  queue_as :default
  require 'csv'

  def perform(report_id, start_date, end_date, protocol_ids, organization_ids)
    CSV.open("tmp/admin_auditing_report.csv", "wb") do |csv|
      csv << ["From", start_date, "To", end_date]
      csv << [""]
      csv << [""]
      csv << ["Protocol ID", "Primary PI", "Patient Name", "Patient ID", "Visit Name", "Visit Date", "Service(s) Completed", "Quantity Completed", "Research Rate", "Total Cost"]

      if protocol_ids
        protocols = Protocol.find(protocol_ids)
      else
        protocols = Protocol.all
      end

      protocols.each do |protocol|
        protocol.procedures.to_a.select{|procedure| procedure.completed_date && (start_date..end_date).cover?(procedure.completed_date)}.delete_if{|procedure| procedure.billing_type != "research_billing_qty"}.group_by(&:service).each do |group, procedures|
          procedure = procedures.first
          participant = procedure.participant
          appointment = procedure.appointment
          csv << [protocol.sparc_id, protocol.try(:pi).full_name, participant.full_name, participant.label, appointment.name, appointment.start_date, procedure.service_name, procedures.size, (procedure.service_cost.to_f / 100), (procedures.size * procedure.service_cost.to_f) / 100]
        end
      end
    end

    report = Report.find(report_id)

    if report.create_document(doc: File.open("tmp/admin_auditing_report.csv"))
      report.status = "Completed"
      report.save
    end
    FayeJob.enqueue(report)
  end
end
