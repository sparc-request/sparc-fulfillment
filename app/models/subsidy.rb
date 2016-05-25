class Subsidy < ActiveRecord::Base
  include SparcShard

  belongs_to :sub_service_request

  default_scope { where(status: "Approved") }

  def subsidy_committed 
    # Calculates cost of subsidy (amount subsidized)
    # stored total - pi_contribution then convert from cents to dollars
    total_at_approval - pi_contribution
  end
end
