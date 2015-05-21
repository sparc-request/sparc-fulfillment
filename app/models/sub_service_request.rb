class SubServiceRequest < ActiveRecord::Base

  include SparcShard

  belongs_to :organization
  belongs_to :service_request

  delegate :protocol, to: :service_request
end

