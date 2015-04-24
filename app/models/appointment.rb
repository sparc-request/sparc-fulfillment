class Appointment < ActiveRecord::Base

  STATUSES = ['Skipped Visit', 'Visit happened elsewhere', 'Patient missed visit', 'No show', 'Visit happened outside of window'].freeze
  NOTABLE_REASONS = ['Assessment not performed', 'SAE/Follow-up for SAE', 'Patient Visit Conflict', 'Study Visit Assessments Inconclusive'].freeze

  default_scope {order(:position)}
  
  has_paper_trail
  acts_as_paranoid
  acts_as_list scope: [:arm_id, :participant_id]

  include CustomPositioning #custom methods around positioning, acts_as_list
  
  has_one :protocol,  through: :participant
  has_many :appointment_statuses, dependent: :destroy

  belongs_to :participant
  belongs_to :visit_group
  belongs_to :arm

  has_many :procedures
  has_many :notes, as: :notable

  scope :completed, -> { where('completed_date IS NOT NULL') }
  
  validates :participant_id, :name, :arm_id, presence: true
  
  accepts_nested_attributes_for :notes

  def has_completed_procedures?
    has_completed = false
    unless self.procedures.empty?
      self.procedures.each do |proc|
        if proc.completed_date
          has_completed = true
        end
      end
    end

    has_completed
  end

  def procedures_grouped_by_core
    procedures.group_by(&:sparc_core_id)
  end

  def set_completed_date
    self.completed_date = Time.now
  end

  def destroy_if_incomplete
    if not (completed_date || has_completed_procedures?)
      self.destroy
    end
  end

  def initialize_procedures
    unless self.is_a? CustomAppointment # custom appointments don't inherit from the study schedule so there is nothing to build out
      ActiveRecord::Base.transaction do
        self.visit_group.arm.line_items.each do |li|
          visit = li.visits.where("visit_group_id = #{self.visit_group.id}").first
          if visit and visit.has_billing?
            attributes = {
              appointment_id: self.id,
              visit_id: visit.id,
              service_name: li.service.name,
              service_cost: li.service.cost,
              service_id: li.service.id,
              sparc_core_id: li.service.sparc_core_id,
              sparc_core_name: li.service.sparc_core_name
            }
            visit.research_billing_qty.times do
              proc = Procedure.new(attributes)
              proc.billing_type = 'research_billing_qty'
              proc.save
            end
            visit.insurance_billing_qty.times do
              proc = Procedure.new(attributes)
              proc.billing_type = 'insurance_billing_qty'
              proc.save
            end
          end
        end
      end
    end
  end

end
