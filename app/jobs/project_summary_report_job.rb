class ProjectSummaryReportJob < ActiveJob::Base
  include ApplicationHelper
  queue_as :default
  require 'csv'

  def perform(report_id, start_date, end_date, protocol_id)
    CSV.open("tmp/project_summary_report.csv", "wb") do |csv|
      protocol = Protocol.find(protocol_id)
      csv << ["SPARC ID: #{protocol.sparc_id}"]
      csv << ["PI Name: #{protocol.pi ? protocol.pi.full_name : nil}"]
      csv << ["?"]
      csv << ["Routing: "]
      csv << ["Appointment Start Date Filter: #{format_date(start_date.to_date)}"]
      csv << ["Appointment End Date Filter: #{format_date(end_date.to_date)}"]
      csv << [""]

      protocol.arms.each do |arm|
        visit_groups = arm.visit_groups
        participants = arm.participants

        csv << [""]
        csv << [arm.name]
        csv << (["PID", "Status"] + visit_groups.pluck(:name))

        participants.each do |participant|
          appointments = visit_groups.map do |vg|
            (appointment = vg.appointments.where(participant: participant).first) ? appointment.total_completed_cost : "N/A"
          end
          csv << (["Subject #{participant.label}", participant.status] + appointments)
        end
      end
    end

    report = Report.find(report_id)

    if report.create_document(doc: File.open("tmp/project_summary_report.csv"))
      report.status = "Completed"
      report.save
    end
    FayeJob.enqueue(report)
  end
end
