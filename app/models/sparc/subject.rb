class Sparc::Subject < ActiveRecord::Base
  include SparcShard

  belongs_to :arm
  has_one :calendar
end
