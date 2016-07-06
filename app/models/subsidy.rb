class Subsidy < ActiveRecord::Base
  include SparcShard

  belongs_to :sub_service_request

  default_scope { where(status: "Approved") }

  def subsidy_committed 
    # Calculates cost of subsidy (amount subsidized)
    # stored total - pi_contribution returning cents
    total_at_approval - pi_contribution
  end

  def percent_subsidy
    if total_at_approval.nil? || total_at_approval == 0
      "0"
    else
      ((total_at_approval - pi_contribution.to_f) / total_at_approval * 100.0).round(2).to_s
    end
  end
end
