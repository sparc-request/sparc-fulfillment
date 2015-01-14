class LineItem < ActiveRecord::Base

  acts_as_paranoid

  belongs_to :arm
  belongs_to :service

  has_many :visit_groups, through: :arm
  has_many :visits, -> { includes(:visit_group).order("visit_groups.position") }, dependent: :destroy

  delegate  :name,
            :cost,
            :sparc_core_id,
            :sparc_core_name,
            to: :service
end
