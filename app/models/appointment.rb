class Appointment < ActiveRecord::Base

  acts_as_paranoid

  belongs_to :participant
  belongs_to :visit_group
  has_many :procedures
end