class ProjectSummaryReport < Report

  VALIDATES_PRESENCE_OF = [:title, :start_date, :end_date, :protocol_id].freeze
  VALIDATES_NUMERICALITY_OF = [].freeze

  require 'csv'

  def generate(document)
    #We want to filter from 00:00:00 in the local time zone,
    #then convert to UTC to match database times
    @start_date = Time.strptime(@params[:start_date], "%m/%d/%Y").utc
    #We want to filter from 11:59:59 in the local time zone,
    #then convert to UTC to match database times
    @end_date   = Time.strptime(@params[:end_date], "%m/%d/%Y").tomorrow.utc - 1.second

    document.update_attributes(content_type: 'text/csv', original_filename: "#{@params[:title]}.csv")

    protocol = Protocol.find(@params[:protocol_id])

    CSV.open(document.path, "wb") do |csv|
      csv << ["SPARC ID:", "#{protocol.sparc_id}"]
      csv << ["PI Name:", "#{protocol.pi ? protocol.pi.full_name : nil}"]
      csv << ["Appointment Start Date Filter:", "#{format_date(Time.strptime(@params[:start_date], "%m/%d/%Y"))}"]
      csv << ["Appointment End Date Filter:", "#{format_date(Time.strptime(@params[:end_date], "%m/%d/%Y"))}"]
      csv << [""]

      # amount due for whole study
      arms_total = 0

      protocol.arms.each do |arm|
        visit_groups          = arm.visit_groups
        visit_group_subtotals = [0] * visit_groups.count # total costs for each visit group
        participants = arm.participants
        participant_totals    = []  # totals per participant

        csv << [""]
        csv << [""]
        csv << [""]
        csv << [""]
        csv << ["Arm Name: #{arm.name}"]
        csv << ["", "Participant ID", "Participant Status", visit_groups.pluck(:name), "Totals"].flatten
        csv << [""]

        participants.each do |participant|
          participant_costs = visit_groups.map do |vg|
            total_completed_cost_for_participant(vg, participant) || "N/A"
          end

          participant_total     = sum_up(participant_costs)
          participant_totals    << participant_total
          visit_group_subtotals = add_parallel_arrays(visit_group_subtotals, participant_costs)

          csv << ["", "Subject #{participant.label}", participant.status, display_cost_array(participant_costs + [participant_total])].flatten
        end

        arm_subtotal = sum_up(visit_group_subtotals)
        csv << [""]
        csv << ["", "Visit Subtotals - #{arm.name}", "", display_cost_array(visit_group_subtotals + [arm_subtotal])].flatten
        arms_total += arm_subtotal
      end

      csv << [""]
      csv << [""]
      csv << [""]
      csv << [""]
      csv << [""]
      csv << [""]
      csv << ["Study Level Charges"]
      csv << ["", "Name", "Cost"]
      csv << [""]

      study_level_charges = 0
      protocol.fulfillments.fulfilled_in_date_range(@start_date, @end_date).each do |f|
        csv << ["", f.service_name, display_cost(f.service_cost)]
        study_level_charges += f.service_cost
      end

      csv << [""]
      csv << [""]
      csv << ["Study Level Charges Total", display_cost(study_level_charges)]
      csv << ["Arms Total", display_cost(arms_total)]
      csv << [""]
      csv << [""]
      csv << ["Study Total", display_cost(arms_total + study_level_charges)]
    end
  end

  private

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

  # Totals the service costs (for completed procedures) rendered
  # for given participant.
  def total_completed_cost_for_participant(vg, participant)
    (appointment = vg.appointments.where(participant: participant).first) ? total_completed_cost(appointment) : nil
  end

  def total_completed_cost(appointment)
    appointment.procedures.completed_r_in_date_range(@start_date, @end_date).sum(:service_cost)
  end
end
