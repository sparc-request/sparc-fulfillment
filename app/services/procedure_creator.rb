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
          percent_subsidy = protocol.sub_service_request.subsidy ? protocol.sub_service_request.subsidy.percent_subsidy : nil
          if visit and visit.has_billing?
            attributes = {
              appointment_id: @appointment.id,
              visit_id: visit.id,
              service_name: li.service.name,
              service_id: li.service.id,
              sparc_core_id: li.service.sparc_core_id,
              sparc_core_name: li.service.sparc_core_name,
              funding_source: li.protocol.sparc_funding_source,
              percent_subsidy: percent_subsidy
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