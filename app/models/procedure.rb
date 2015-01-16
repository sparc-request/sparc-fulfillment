class Procedure < ActiveRecord::Base

  acts_as_paranoid

  belongs_to :appointment
  has_many :notes
end