class PricingMap < ActiveRecord::Base

  include SparcShard

  belongs_to :service

  scope :current, -> (date) { where("effective_date <= ?", date).order("effective_date DESC").limit(1) }

##  COPIED FROM SPARC-REQUEST    ##
  def applicable_rate(rate_type, default_percentage)
    rate = rate_override(rate_type)
    rate ||= calculate_rate(default_percentage)

    rate
  end

  def rate_override(rate_type)
    case rate_type
    when 'federal'    then self.federal_rate
    when 'corporate'  then self.corporate_rate
    when 'member'     then self.member_rate
    when 'other'      then self.other_rate
    when 'full'       then self.full_rate
    else raise ArgumentError, "Could not find rate for #{rate_type}"
    end
  end

  def calculate_rate(default_percentage)
    self.full_rate.to_f * default_percentage
  end
##  COPIED FROM SPARC-REQUEST END ##
end
