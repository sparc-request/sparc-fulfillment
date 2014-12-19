class VisitGroup < ActiveRecord::Base
  self.per_page = 5

  acts_as_paranoid
  after_create :reorder_visit_groups_up, :create_visits
  after_destroy :reorder_visit_groups_down

  belongs_to :arm

  has_many :visits, :dependent => :destroy
  has_many :line_items, through: :arm

  default_scope {order(:position)}

  accepts_nested_attributes_for :visits

  validates :arm_id, presence: true
  validates :position, presence: true
  validates :name, presence: true
  validates :day, presence: true, numericality: true

  private
  def reorder_visit_groups_up
    VisitGroup.where("arm_id = ? AND position >= ?", self.arm_id, self.position).each do |group|
      group.update_attributes(position: group.position + 1) unless group == self
    end
  end

  def reorder_visit_groups_down
    VisitGroup.where("arm_id = ? AND position >= ?", self.arm_id, self.position).each do |group|
      group.update_attributes(position: group.position - 1) unless group == self
    end
  end

  def create_visits
    new_visits = []
    self.line_items.pluck(:id).each do |li|
      new_visits << Visit.new(visit_group_id: self.id, line_item_id: li, research_billing_qty: 0, insurance_billing_qty: 0, effort_billing_qty: 0)
    end
    Visit.import new_visits
  end
end
