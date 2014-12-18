class LineItem < ActiveRecord::Base
  acts_as_paranoid

  default_scope { order(:sparc_core_name) }

  belongs_to :arm
  belongs_to :service

  has_many :visits, -> { includes(:visit_group).order("visit_groups.position") }, :dependent => :destroy

  accepts_nested_attributes_for :visits
end
