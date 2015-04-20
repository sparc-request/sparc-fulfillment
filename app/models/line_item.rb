class LineItem < ActiveRecord::Base

  has_paper_trail
  acts_as_paranoid

  belongs_to :protocol
  belongs_to :arm
  belongs_to :service

  has_many :visit_groups, through: :arm
  has_many :visits, -> { includes(:visit_group).order("visit_groups.position") }, dependent: :destroy
  has_many :notes, as: :notable
  has_many :documents

  delegate  :name,
            :cost,
            :sparc_core_id,
            :sparc_core_name,
            to: :service
end
