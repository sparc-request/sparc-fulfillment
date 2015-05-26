class AuditingReportJob < ActiveJob::Base
  queue_as :default
  require 'csv'

  def perform(report_id, start_date, end_date, protocol_ids)
    CSV.open("tmp/admin_auditing_report.csv", "wb") do |csv|
      csv << ["From", start_date, "To", end_date]
      csv << [""]
      csv << [""]
      csv << ["Protocol ID", "Patient Name", "Patient ID", "Arm", "Visit", "Visit Date", "Nexus Core", "Service Due", "Research # Due", "Research # Completed?", "If expected not completed, reason?", "Total cost", "T # due", "T # completed"]

      if protocol_ids
        protocols = Protocol.find(protocol_ids)
      else
        protocols = Protocol.all
      end

      protocols.each do |protocol|
        protocol.procedures.to_a.select{|procedure| procedure.appointment.completed_date && (start_date..end_date).cover?(procedure.appointment.completed_date)}.group_by(&:service).each do |group, procedures|
          r_count = procedures.count{|p| p.billing_type == "research_billing_qty"}
          t_count = procedures.count{|p| p.billing_type == "insurance_billing_qty"}

          procedure = procedures.first
          participant = procedure.participant
          appointment = procedure.appointment
          csv << [protocol.sparc_id, participant.full_name, participant.label, appointment.arm.name, appointment.name, appointment.completed_date, procedure.service.organization.name, procedure.service_name, "R Due", "R Completed", "Why Not?", "Total Cost", "T Due", "T Completed"]
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

##########Notes##########
#Is "Visit Date" the completed date of the appointment?
#For the start and end date, am I checking the beginning, or the end of the appointment?
#Does total cost include the "T" stuff?
#What do I do with "O" billing type? Just ignore it?
#Why not column doesn't make sense. Each of these entries represents multiple procedures, which could each have a "reason."
