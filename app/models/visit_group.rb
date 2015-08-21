class VisitGroup < ActiveRecord::Base
  self.per_page = Visit.per_page

  has_paper_trail
  acts_as_paranoid
  acts_as_list scope: [:arm_id]

  include CustomPositioning #custom methods around positioning, acts_as_list

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

  def r_quantities_grouped_by_service
    visits.joins(:line_item).group(:service_id).sum(:research_billing_qty)
  end

  def t_quantities_grouped_by_service
    visits.joins(:line_item).group(:service_id).sum(:insurance_billing_qty)
  end

  private

  def check_for_completed_data
    self.appointments.each{ |appt| appt.destroy_if_incomplete }
  end
end
