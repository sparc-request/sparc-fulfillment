class VisitGroup < ActiveRecord::Base
  self.per_page = Visit.per_page

  acts_as_paranoid

  after_create :reorder_visit_groups_up
  after_destroy :reorder_visit_groups_down
  before_destroy :check_for_completed_data

  belongs_to :arm

  has_many :visits, :dependent => :destroy
  has_many :line_items, through: :arm
  has_many :appointments

  default_scope {order(:position)}

  validates :arm_id,
            :name,
            presence: true
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
      self.update_attributes(position: (VisitGroup.where("arm_id = ?", self.arm_id)).count)
    end
  end

  def reorder_visit_groups_down
    VisitGroup.where("arm_id = ? AND position >= ?", self.arm_id, self.position).each do |group|
      group.update_attributes(position: group.position - 1) unless group == self
    end
  end

  def check_for_completed_data
    self.appointments.each do |appt|
      unless (appt.completed_date || appt.has_completed_procedures?)
        appt.destroy
      end
    end
  end
end
