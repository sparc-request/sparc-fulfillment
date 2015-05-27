class AuditingReportJob < ActiveJob::Base
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper
  queue_as :default
  require 'csv'

  def perform(report_id, start_date, end_date, protocol_ids)
    CSV.open("tmp/admin_auditing_report.csv", "wb") do |csv|
      csv << ["From", start_date, "To", end_date]
      csv << [""]
      csv << [""]
      csv << ["Protocol ID", "Patient Name", "Patient ID", "Arm Name", "Visit Name", "Performed Date", "Nexus Core", "Service Due", "Billing Type", "If not completed, reason?", "Cost"]

      if protocol_ids
        protocols = Protocol.find(protocol_ids)
      else
        protocols = Protocol.all
      end

      protocols.each do |protocol|
        protocol.procedures.to_a.select{|procedure| procedure.appointment.completed_date && procedure.completed_date && (start_date..end_date).cover?(procedure.completed_date)}.each do |procedure|
          participant = procedure.appointment.participant
          csv << [protocol.sparc_id, participant.full_name, participant.label, procedure.appointment.arm.name, procedure.appointment.name, procedure.completed_date, procedure.service.organization.name, procedure.service_name, procedure.formatted_billing_type, procedure.reason, display_cost(procedure.service_cost)]
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
