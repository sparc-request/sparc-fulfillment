class ProjectSummaryReportJob < ActiveJob::Base
  include ActionView::Helpers::NumberHelper
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

      amount_due = 0

      protocol.arms.each do |arm|
        visit_groups          = arm.visit_groups
        visit_group_subtotals = [0] * visit_groups.count
        participants          = arm.participants
        participant_totals    = []

        csv << [""]
        csv << [arm.name]
        csv << ["PID", "Status", visit_groups.pluck(:name), "Totals"].flatten

        participants.each do |participant|
          participant_costs = visit_groups.map do |vg|
            vg.total_completed_cost_for_participant(participant) || "N/A"
          end

          participant_total = participant_costs.reject { |a| a == "N/A" }.reduce(0, :+)

          participant_totals << participant_total
          visit_group_subtotals = visit_group_subtotals.
                                    zip(participant_costs).
                                    map { |a, b| a + b }

          csv << ["Subject #{participant.label}", participant.status, display_cost_array(participant_costs + [participant_total])].flatten
        end

        arm_total = visit_group_subtotals.reduce(0, :+)
        csv << ["Visit Subtotals - #{arm.name}", "", display_cost_array(visit_group_subtotals + [arm_total])].flatten
        amount_due += arm_total
      end

      one_time_fees = protocol.one_time_fees(start_date, end_date)
      csv << ["One Time Fees", display_cost(one_time_fees)]
      csv << ["Study Totals", display_cost(amount_due += one_time_fees)]
      csv << ["Amount Due", display_cost(amount_due)]
    end

    report = Report.find(report_id)

    if report.create_document(doc: File.open("tmp/project_summary_report.csv"))
      report.status = "Completed"
      report.save
    end
    FayeJob.enqueue(report)
  end

  def display_cost_array(cost_array)
    cost_array.map{|cost| display_cost(cost)}
  end
end
