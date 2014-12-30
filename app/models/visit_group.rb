class VisitGroup < ActiveRecord::Base
  self.per_page = 6

  acts_as_paranoid

  belongs_to :arm

  has_many :visits, :dependent => :destroy

  accepts_nested_attributes_for :visits
end
