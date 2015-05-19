class ServiceLevelComponent < ActiveRecord::Base

  include SparcShard

  belongs_to :service
end
