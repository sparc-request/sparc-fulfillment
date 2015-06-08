class Sparc::VisitGroup < ActiveRecord::Base
  
  include SparcShard

  belongs_to :arm
  has_many :visits
end
