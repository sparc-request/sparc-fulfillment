class Sparc::ServiceRequest < ActiveRecord::Base
  
  include SparcShard

  belongs_to :service_requester, :class_name => "Identity", :foreign_key => "service_requester_id"
  belongs_to :protocol
  has_many :sub_service_requests
  has_many :line_items

  has_many :arms, :through => :protocol
end