class Sparc::PricingMap < ActiveRecord::Base

  include SparcShard

  belongs_to :service
end
