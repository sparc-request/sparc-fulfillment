class Appointment < ActiveRecord::Base

  acts_as_paranoid

  belongs_to :participant
  belongs_to :visit_group
  has_many :procedures

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

  def initialize_procedures
    ActiveRecord::Base.transaction do
      if self.procedures.empty?
        self.visit_group.arm.line_items.each do |li|
          visit = li.visits.where("visit_group_id = #{self.visit_group.id}").first
          if visit and visit.has_billing?
            r_value, t_value = visit.research_billing_qty, visit.insurance_billing_qty
            attributes = {
              appointment_id: self.id,
              service_name: li.service.name,
              service_cost: li.service.cost,
              service_id: li.service.id,
              status: "incomplete",
              sparc_core_id: li.service.sparc_core_id,
              sparc_core_name: li.service.sparc_core_name
            }
            r_value.times do
              proc = Procedure.new(attributes)
              proc.billing_type = 'R'
              proc.save
            end
            t_value.times do
              proc = Procedure.new(attributes)
              proc.billing_type = 'T'
              proc.save
            end
          end
        end
      end
    end
  end
end