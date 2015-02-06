class Visit < ActiveRecord::Base
  self.per_page = 6

  acts_as_paranoid

  belongs_to :line_item
  belongs_to :visit_group

  delegate :position, to: :visit_group

  has_many :procedures

  def has_billing?
    research_billing_qty > 0 ||
      insurance_billing_qty > 0 ||
        effort_billing_qty > 0
  end

  def update_procedures updated_qty, selected_qty_type = "research_billing_qty"
    service = self.line_item.service
    new_procedure_values  = []
    new_procedure_columns = [:visit_id, :service_id, :service_name, :service_cost, :status, :billing_type, :sparc_core_id, :sparc_core_name, :appointment_id]
    self.visit_group.arm.participants.each do |participant|
      appointment = participant.appointments.where("visit_group_id = ?", self.visit_group.id).first
      next if appointment.nil?
      procedures_available = self.procedures.where("billing_type = ? AND service_id = ? AND appointment_id = ?", selected_qty_type, service.id, appointment.id)
      current_qty = procedures_available.count
      if current_qty > updated_qty
        procedures_to_delete = procedures_available.where("completed_date is null").limit(current_qty - updated_qty)
        if not procedures_to_delete.empty?
          procedures_to_delete.destroy_all
        end
      elsif current_qty < updated_qty
        (updated_qty - current_qty).times do
          new_procedure_values << [self.id, service.id, service.name, service.cost, "incomplete", selected_qty_type, service.sparc_core_id, service.sparc_core_name, appointment.id]
        end
      end
    end
    Procedure.import new_procedure_columns, new_procedure_values, {validate: true}
    puts "*" * 80
  end
end
