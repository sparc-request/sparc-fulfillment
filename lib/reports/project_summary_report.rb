# Copyright © 2011-2017 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

class ProjectSummaryReport < Report

  VALIDATES_PRESENCE_OF = [:title, :start_date, :end_date, :protocol].freeze
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

    protocol = Protocol.find(@params[:protocol])

    CSV.open(document.path, "wb") do |csv|
      csv << ["SPARC ID:", "#{protocol.sparc_id}"]
      csv << ["PI Name:", "#{protocol.pi ? protocol.pi.full_name : nil}"]
      csv << ["From:", "#{format_date(Time.strptime(@params[:start_date], "%m/%d/%Y"))}"]
      csv << ["To:", "#{format_date(Time.strptime(@params[:end_date], "%m/%d/%Y"))}"]
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
        csv << ["Clinical Services"]
        csv << ["Arm Name: #{arm.name}","","","","","","Invoiceable Visit Cost"]
        csv << ["", "Patient MRN", "Participant Status", visit_groups.pluck(:name), "Per Patient Invoiceable Total"].flatten
        csv << [""]

        participants.each do |participant|
          participant_costs = visit_groups.map do |vg|
            total_completed_cost_for_participant(vg, participant) || "N/A"
          end

          participant_total     = sum_up(participant_costs)
          participant_totals    << participant_total
          visit_group_subtotals = add_parallel_arrays(visit_group_subtotals, participant_costs)

          csv << ["", "#{participant.mrn}", participant.status, display_cost_array(participant_costs + [participant_total])].flatten
        end

        arm_subtotal = sum_up(visit_group_subtotals)
        csv << [""]
        csv << ["", "#{arm.name} Total", "", display_cost_array(visit_group_subtotals + [arm_subtotal])].flatten
        arms_total += arm_subtotal
      end

      csv << [""]
      csv << ["Clinical Services Invoiceable Total", display_cost(arms_total)]
      csv << [""]
      csv << ["Non-Clinical Services"]
      csv << ["", "Service", "Quantity Completed", "Quantity Type", "Cost"]
      csv << [""]

      study_level_charges = 0
      protocol.fulfillments.fulfilled_in_date_range(@start_date, @end_date).each do |f|
        csv << ["", f.service_name, f.quantity.to_s, f.line_item.try(:quantity_type), display_cost(f.service_cost)]
        study_level_charges += f.service_cost
      end

      csv << [""]
      csv << [""]
      csv << ["Non-Clinical Services Invoiceable Total", "", "", "", display_cost(study_level_charges)]
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
