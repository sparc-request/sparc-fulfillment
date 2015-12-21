class PricingSetup < ActiveRecord::Base

  include SparcShard

  belongs_to :organization

  scope :current, -> (date) { where("effective_date <= ?", date).order("effective_date DESC").limit(1) }

  def rate_type(funding_source)
    case funding_source
    when 'college'       then self.college_rate_type
    when 'federal'       then self.federal_rate_type
    when 'foundation'    then self.foundation_rate_type
    when 'industry'      then self.industry_rate_type
    when 'investigator'  then self.investigator_rate_type
    when 'internal'      then self.internal_rate_type
    when 'unfunded'      then self.unfunded_rate_type
    else raise ArgumentError, "Could not find rate type for funding source #{funding_source}"
    end
  end

  def rate_type_percentage(type)
    case type
    when 'federal'   then  ( self.federal / 100 )
    when 'corporate' then  ( self.corporate / 100 )
    when 'member'    then  ( self.member / 100 )
    when 'other'     then  ( self.other / 100 )
    else 1.0
    end
  end
end
