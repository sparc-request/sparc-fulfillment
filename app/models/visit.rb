class Visit < ActiveRecord::Base

  self.per_page = 8

  has_paper_trail
  acts_as_paranoid

  belongs_to :line_item
  belongs_to :visit_group

  has_many :procedures

  delegate :position, to: :visit_group
  validates_numericality_of :research_billing_qty, :insurance_billing_qty, :effort_billing_qty, greater_than_or_equal_to: 0

  def destroy
    procedures.untouched.belonging_to_unbegun_appt.map(&:destroy)

    super
  end

  def has_billing?
    research_billing_qty > 0 ||
      insurance_billing_qty > 0 ||
        effort_billing_qty > 0
  end

  def total_quantity
    research_billing_qty + insurance_billing_qty
  end

  def update_procedures updated_qty, selected_qty_type
    service = self.line_item.service
    new_procedure_values  = []
    new_procedure_columns = [:visit_id, :service_id, :service_name, :billing_type, :sparc_core_id, :sparc_core_name, :appointment_id]
    self.visit_group.arm.participants.each do |participant|
      appointment = participant.appointments.where("visit_group_id = ?", self.visit_group.id).first
      next if (appointment.nil? || appointment.completed_date?)
      
      unless appointment.procedures.empty?
        procedures_available = self.procedures.where("billing_type = ? AND service_id = ? AND appointment_id = ?", selected_qty_type, service.id, appointment.id)
        current_qty = procedures_available.count
        if current_qty > updated_qty and appointment.start_date.nil?    # don't delete procedures from begun appointments
          procedures_to_delete = procedures_available.untouched.limit(current_qty - updated_qty)
          if not procedures_to_delete.empty?
            procedures_to_delete.destroy_all
          end
        elsif current_qty < updated_qty
          (updated_qty - current_qty).times do
            new_procedure_values << [self.id, service.id, service.name, selected_qty_type, service.sparc_core_id, service.sparc_core_name, appointment.id]
          end
        end
      end
    end
    Procedure.import new_procedure_columns, new_procedure_values, {validate: true}
  end
end
