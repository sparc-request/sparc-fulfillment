class LineItem < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :arm
  belongs_to :service

  has_many :visits, :dependent => :destroy

  accepts_nested_attributes_for :visits
end
