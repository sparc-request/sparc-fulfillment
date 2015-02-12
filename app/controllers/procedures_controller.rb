class ProceduresController < ApplicationController
  def create
    @appointment_id = params[:appointment_id]
    qty = params[:qty].to_i
    service = Service.find params[:service_id]
    @core_id = service.sparc_core_id
    @core_name = service.sparc_core_name
    @procedures = []
    qty.times do
      @procedures << Procedure.create(appointment_id: @appointment_id,
                                      service_id: service.id,
                                      service_name: service.name,
                                      billing_type: 'research_billing_qty',
                                      sparc_core_id: @core_id,
                                      sparc_core_name: @core_name)
    end
  end

  def destroy
    procedure = Procedure.find params[:id]
    @procedure_id = params[:id]
    @core_id = procedure.sparc_core_id

    procedure.destroy
  end
end
