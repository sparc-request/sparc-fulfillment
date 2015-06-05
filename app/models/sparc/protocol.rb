class Sparc::Protocol < ActiveRecord::Base
  self.inheritance_column = nil # ignore STI
  
  include SparcShard

  has_many :service_requests
  has_many :arms
end
