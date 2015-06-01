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
      csv << ["Protocol ID", "Patient Name", "Patient ID", "Arm Name", "Visit Name", "Service Completion Date", "Marked as Incomplete Date", "Marked with Follow-Up Date", "Added?", "Nexus Core", "Service Name", "Completed?", "Billing Type (R/T/O)", "If not completed, reason or F/U", "Cost"]

      if protocol_ids
        protocols = Protocol.find(protocol_ids)
      else
        protocols = Protocol.all
      end

      protocols.each do |protocol|
        protocol.procedures.to_a.select{|procedure| procedure.appointment.completed_date && !procedure.unstarted? && (start_date..end_date).cover?(procedure.handled_date)}.each do |procedure|
          participant = procedure.appointment.participant
          csv << [protocol.sparc_id, participant.full_name, participant.label, procedure.appointment.arm.name, procedure.appointment.name, procedure.completed_date, procedure.incompleted_date, procedure.handled_date, added(procedure), procedure.service.organization.name, procedure.service_name, procedure.complete? ? "Yes" : "No", procedure.formatted_billing_type, reason_follow_up(procedure), display_cost(procedure.service_cost)]
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

  private

  def added(procedure)
    procedure.visit? ? "" : "**Added**"
  end

  def reason_follow_up(procedure)
    text = ""
    if procedure.incomplete && procedure.reason
      text = "#{procedure.reason} "
    end
    if procedure.task
      text = text + "Follow-Up Due Date: #{procecure.task.due_at}"
    end

    return text
  end

end


