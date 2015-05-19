class Arm < ActiveRecord::Base

  has_paper_trail if: Rails.env.production?
  acts_as_paranoid

  belongs_to :protocol

  has_many :line_items, dependent: :destroy
  has_many :visit_groups, dependent: :destroy
  has_many :appointments
  has_many :participants

  validates :name, presence: true
  validates_numericality_of :subject_count, greater_than_or_equal_to: 1
  validates_numericality_of :visit_count, greater_than_or_equal_to: 1

  def line_items_grouped_by_core
    line_items.includes(:service).group_by(&:sparc_core_id)
  end
end
