class VisitGroup < ActiveRecord::Base
  self.per_page = Visit.per_page

  acts_as_paranoid
  after_create :reorder_visit_groups_up, :create_visits
  after_destroy :reorder_visit_groups_down

  belongs_to :arm

  has_many :visits, :dependent => :destroy
  has_many :line_items, through: :arm

  default_scope {order(:position)}

  accepts_nested_attributes_for :visits

  validates :arm_id, presence: true
  validates :name, presence: true
  validates :day, presence: true, numericality: true

  def insertion_name
    "insert before " + self.name
  end

  private
  def reorder_visit_groups_up
    if self.position != nil
      VisitGroup.where("arm_id = ? AND position >= ?", self.arm_id, self.position).each do |group|
        group.update_attributes(position: group.position + 1) unless group == self
      end
    else
      self.update_attributes(position: (VisitGroup.where("arm_id = ?", self.arm_id)).count + 1)
    end
  end

  def reorder_visit_groups_down
    VisitGroup.where("arm_id = ? AND position >= ?", self.arm_id, self.position).each do |group|
      group.update_attributes(position: group.position - 1) unless group == self
    end
  end

  def create_visits
    new_visit_columns = [:visit_group_id, :line_item_id, :research_billing_qty, :insurance_billing_qty, :effort_billing_qty]
    new_visit_values = []
    self.line_items.pluck(:id).each do |li|
      new_visit_values << [self.id, li, 0, 0, 0]
    end
    Visit.import new_visit_columns, new_visit_values, {validate: true}
  end
end
