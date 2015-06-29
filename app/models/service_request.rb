class ServiceRequest < ActiveRecord::Base

  include SparcShard

  belongs_to :protocol
  belongs_to :requester, class_name: 'Identity'

  has_many :sub_service_requests
end
