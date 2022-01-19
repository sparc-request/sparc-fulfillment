class ProcedureCreator

  def initialize(appointment)
    @appointment = appointment
  end

  def initialize_procedures
    unless @appointment.is_a? CustomAppointment # custom appointments don't inherit from the study schedule so there is nothing to build out
      ActiveRecord::Base.transaction do
        @appointment.visit_group.arm.line_items.each do |li|
          visit = li.visits.where("visit_group_id = #{@appointment.visit_group.id}").first
          protocol = @appointment.protocol
          if visit and visit.has_billing?
            attributes = {
              appointment_id: @appointment.id,
              visit_id: visit.id,
              service_name: li.service.name,
              service_id: li.service.id,
              sparc_core_id: li.service.sparc_core_id,
              sparc_core_name: li.service.sparc_core_name
            }
            visit.research_billing_qty.times do
              procedure = Procedure.new(attributes)
              procedure.billing_type = 'research_billing_qty'
              procedure.save
            end
            visit.insurance_billing_qty.times do
              procedure = Procedure.new(attributes)
              procedure.billing_type = 'insurance_billing_qty'
              procedure.save
            end
          end
        end
      end
    end
  end
end