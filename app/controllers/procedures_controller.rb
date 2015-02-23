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

  def edit
    @procedure = Procedure.find(params[:id])
    @note = Note.new
  end

  def update
    @procedure = Procedure.find(params[:id])
    @date = params[:procedure][:follow_up_date]
    @has_date = @date.length > 0

    if @has_date or not @procedure.follow_up_date.blank?
      @procedure.update_attributes(follow_up_date: @date)
      if @has_date
        end_comment = "Follow Up - #{@date}"
      else
        end_comment = "Follow Up Date Removed"
      end
      end_comment += " - #{params[:note][:comment]}" if params[:note][:comment].length > 0
      Note.create(procedure: @procedure, user_id: current_user.id, user_name: current_user.full_name, comment: end_comment)
    end
  end
end
