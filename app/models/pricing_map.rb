class PricingMap < ActiveRecord::Base

  include SparcShard

  belongs_to :service

  scope :current, -> (date) { where("effective_date <= ?", date).order("effective_date DESC").limit(1) }
end
