class VisitGroup < ActiveRecord::Base
  acts_as_paranoid
  after_create :reorder_visit_groups_up
  after_destroy :reorder_visit_groups_down
  belongs_to :arm
  has_many :visits, :dependent => :destroy

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



end
