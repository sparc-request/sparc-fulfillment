class Sparc::ServiceRequest < ActiveRecord::Base
  
  include SparcShard

  belongs_to :protocol
  has_many :sub_service_requests
  has_many :line_items

  has_many :arms, :through => :protocol
end
