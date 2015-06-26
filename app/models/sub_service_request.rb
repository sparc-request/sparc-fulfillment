class SubServiceRequest < ActiveRecord::Base

  include SparcShard

  has_one :protocol

  belongs_to :owner, class_name: 'Identity'
  belongs_to :organization
  belongs_to :service_request

  delegate :requester, to: :service_request
end
