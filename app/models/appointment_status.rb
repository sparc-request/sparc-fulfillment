class AppointmentStatus < ActiveRecord::Base

  acts_as_paranoid

  belongs_to :appointment
end