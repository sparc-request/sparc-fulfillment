class VisitGroup < ActiveRecord::Base
  self.per_page = Visit.per_page

  has_paper_trail
  acts_as_paranoid
  acts_as_list scope: [:arm_id]

  include CustomPositioning #custom methods around positioning, acts_as_list

  before_destroy :check_for_completed_data

  belongs_to :arm

  has_many :visits, dependent: :destroy
  has_many :line_items, through: :arm
  has_many :appointments

  default_scope { order(:position) }

  validates :arm_id,
            :name,
            :position,
            presence: true

  validates :day, presence: true, unless: "ENV.fetch('USE_EPIC'){nil} == 'false'"

  validate :day_must_be_in_order, unless: "day.blank? || arm_id.blank?"
  validates :day, numericality: { only_integer: true }, unless: "day.blank?"

  def r_quantities_grouped_by_service
    visits.joins(:line_item).group(:service_id).sum(:research_billing_qty)
  end

  def t_quantities_grouped_by_service
    visits.joins(:line_item).group(:service_id).sum(:insurance_billing_qty)
  end

  private

  def check_for_completed_data
    self.appointments.each { |appt| appt.destroy_if_incomplete }
  end

  # Used to validate :day, when present. Preceding VisitGroup must have a
  # a smaller :day, and succeeding VisitGroup must have a larger :day (on same Arm).
  def day_must_be_in_order
    # these VisitGroups will be moved up a position after validations/save
    will_insert_before_days = arm.visit_groups.where(position: position).where.not(id: id).pluck(:day)

    # act_as_list's higher_item returns VisitGroup with the lower position, etc.
    unless day > (higher_item.try(:day) || day - 1) && day < (lower_item.try(:day) || day + 1) && will_insert_before_days.all? { |d| d > day }
      errors.add(:day, 'must be in order')
    end
  end
end
