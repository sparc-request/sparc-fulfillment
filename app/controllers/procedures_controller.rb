class ProceduresController < ApplicationController

  before_action :find_procedure, only: [:edit, :update, :destroy]
  before_action :save_original_procedure_status, only: [:update]
  before_action :create_note_before_update, only: [:update]

  def create
    @appointment_id = params[:appointment_id]
    qty = params[:qty].to_i
    service = Service.find params[:service_id]
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

  def edit
    if params[:partial].present?
      @note = @procedure.notes.new(kind: 'reason')

      render params[:partial]
    else
      render
    end
  end

  def update
    @procedure.update_attributes(procedure_params)
  end

  def destroy
    @procedure.destroy
  end

  private

  def save_original_procedure_status
    @original_procedure_status = @procedure.status
  end

  def create_note_before_update
    if incomplete_status_detected?
      @procedure.notes.create(user: current_user,
                              comment: 'Set to incomplete',
                              kind: 'log')
    elsif complete_status_detected?
      @procedure.notes.create(user: current_user,
                              comment: 'Set to complete',
                              kind: 'log')
    end
  end

  def incomplete_status_detected?
    procedure_params[:status] == "incomplete"
  end

  def complete_status_detected?
    @original_procedure_status != "complete" && procedure_params[:status] == "complete"
  end

  def procedure_params
    params.
      require(:procedure).
      permit(:status, :follow_up_date, :completed_date, notes_attributes: [:comment, :kind, :user_id, :reason])
  end

  def find_procedure
    @procedure = Procedure.where(id: params[:id]).first
  end
end
