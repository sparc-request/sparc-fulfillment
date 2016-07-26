class Subsidy < ActiveRecord::Base
  include SparcShard

  belongs_to :sub_service_request

  default_scope { where(status: "Approved") }

  def subsidy_committed 
    # Calculates cost of subsidy (amount subsidized)
    # stored total - pi_contribution returning cents
    total_at_approval - pi_contribution
  end

  def pi_contribution
    # This ensures that if pi_contribution is null (new record),
    # then it will reflect the full cost of the request.
    total_at_approval.to_f - (total_at_approval.to_f * percent_subsidy) || total_at_approval.to_f
  end
end
