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

      # amount due for whole study
      amount_due = 0

      protocol.arms.each do |arm|
        visit_groups          = arm.visit_groups
        visit_group_subtotals = [0] * visit_groups.count # total costs for each visit group
        participants          = arm.participants
        participant_totals    = []  # totals per participant

        csv << [""]
        csv << ["Arm: #{arm.name}"]
        csv << ["Participant ID", "Status", visit_groups.pluck(:name), "Totals"].flatten

        participants.each do |participant|
          participant_costs = visit_groups.map do |vg|
            vg.total_completed_cost_for_participant(participant) || "N/A"
          end

          participant_total     = sum_up(participant_costs)
          participant_totals    << participant_total
          visit_group_subtotals = add_parallel_arrays(visit_group_subtotals, participant_costs)

          csv << ["Subject #{participant.label}", participant.status, display_cost_array(participant_costs + [participant_total])].flatten
        end

        arm_total = sum_up(visit_group_subtotals)
        csv << [""]
        csv << ["Visit Subtotals - #{arm.name}", "", display_cost_array(visit_group_subtotals + [arm_total])].flatten
        amount_due += arm_total
      end

      csv << [""]
      csv << ["One Time Fees"]
      csv << ["Name", "Cost"]

      one_time_fees = 0
      protocol.fulfillments.fulfilled_in_date_range(start_date, end_date).each do |f|
        csv << [f.service_name, format_cost(f.service_cost)]
        one_time_fees += f.service_cost
      end

      csv << ["Total", "", display_cost(one_time_fees)]
      csv << [""]
      csv << ["Study Totals", display_cost(amount_due += one_time_fees)]
      csv << [""]
      csv << ["Amount Due", display_cost(amount_due)]
    end

    report = Report.find(report_id)

    if report.create_document(doc: File.open("tmp/project_summary_report.csv"))
      report.status = "Completed"
      report.save
    end
    FayeJob.enqueue(report)
  end

  # If n is "N/A", return 0; otherwise, return n
  def na_to_0(n)
    n == "N/A" ? 0 : n
  end

  # [100, "N/A", 350] -> ["$1.00", "N/A", "$3.50"]
  def display_cost_array(cost_array)
    cost_array.map{ |cost| cost == "N/A" ? "N/A" : display_cost(cost) }
  end

  # [0, 1, "N/A"], [3, 4, 5] -> [3, 5, 5]
  def add_parallel_arrays(a1, a2)
    a1.zip(a2).map { |a, b| na_to_0(a) + na_to_0(b) }
  end

  # [0, 1, "N/A", 2] -> 3
  def sum_up(array)
    array.reject { |a| a == "N/A" }.reduce(0, :+)
  end
end
