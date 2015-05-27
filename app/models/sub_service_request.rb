class SubServiceRequest < ActiveRecord::Base

  include SparcShard

  has_one :protocol, :foreign_key => :sparc_sub_service_request_id

  belongs_to :organization
  belongs_to :service_request
end
