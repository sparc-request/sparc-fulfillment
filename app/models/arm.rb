class Arm < ActiveRecord::Base

  acts_as_paranoid

  belongs_to :protocol

  has_many :line_items, dependent: :destroy
  has_many :visit_groups, dependent: :destroy
  has_many :participants

  accepts_nested_attributes_for :line_items, :visit_groups

  validates :name, presence: true
  validates_numericality_of :subject_count, greater_than_or_equal_to: 1
  validates_numericality_of :visit_count, greater_than_or_equal_to: 1

  after_create :create_visit_groups

  def line_items_grouped_by_core
    line_items.includes(:service).group_by(&:sparc_core_id)
  end

  private

  def create_visit_groups
    new_visit_group_columns = [:name, :day, :position, :arm_id]
    new_visit_group_values  = []

    for count in 1..self.visit_count
      new_visit_group_values << ["Visit "+ count.to_s, count, count, self.id]
    end
    VisitGroup.import new_visit_group_columns, new_visit_group_values, { validate: true }
  end

end
