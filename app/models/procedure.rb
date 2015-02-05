class Procedure < ActiveRecord::Base

  acts_as_paranoid

  belongs_to :appointment
  belongs_to :visit

  has_many :notes

  scope :incomplete,  -> { where('completed_date IS NULL') }
  scope :complete,    -> { where('completed_date IS NOT NULL') }
end
