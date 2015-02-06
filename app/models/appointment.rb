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

  def services_grouped_by_core
    self.procedures.group_by(&:sparc_core_id)
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
            status: "incomplete",
            sparc_core_id: li.service.sparc_core_id,
            sparc_core_name: li.service.sparc_core_name
          }
          visit.research_billing_qty.times do
            proc = Procedure.new(attributes)
            proc.billing_type = 'R'
            proc.save
          end
          visit.insurance_billing_qty.times do
            proc = Procedure.new(attributes)
            proc.billing_type = 'T'
            proc.save
          end
        end
      end
    end
  end

end
