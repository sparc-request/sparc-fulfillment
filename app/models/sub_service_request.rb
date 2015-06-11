class SubServiceRequest < ActiveRecord::Base

  include SparcShard

  has_one :protocol

  belongs_to :organization
  belongs_to :service_request
end
