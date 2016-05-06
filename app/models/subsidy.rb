class Subsidy < ActiveRecord::Base
  include SparcShard

  belongs_to :sub_service_request
end