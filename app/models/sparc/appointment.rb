class Sparc::Appointment < ActiveRecord::Base
  include SparcShard
  
  belongs_to :calendar
  belongs_to :visit_group
  belongs_to :organization

  has_many :procedures
  has_many :notes
end
