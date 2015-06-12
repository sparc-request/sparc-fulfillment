class ServiceRequest < ActiveRecord::Base

  include SparcShard

  belongs_to :protocol

  has_many :sub_service_requests
end