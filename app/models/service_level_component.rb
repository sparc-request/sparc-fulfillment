class ServiceLevelComponent < ActiveRecord::Base

  include SparcShard

  belongs_to :service, counter_cache: true
end
