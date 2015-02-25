class AppointmentCalendarController < ApplicationController

  def complete_procedure
    @procedure = Procedure.find(params[:procedure_id])
    @procedure.update_attributes(status: "complete", completed_date: Time.now)
    Note.create(procedure_id: @procedure.id, user_id: current_user.id, user_name: current_user.full_name, comment: "Set to completed")
  end

  def new_incomplete_procedure
    @procedure = Procedure.find(params[:procedure_id])
  end

  def create_incomplete_procedure
    @procedure = Procedure.find(params[:procedure_id])
    @procedure.update_attributes(status: "incomplete", reason: params[:reasons_selectpicker])
    comment = params[:comment] == " " ? "Set to incomplete because of #{params[:reasons_selectpicker]}" : params[:comment]
    Note.create(procedure_id: @procedure.id, comment: comment, user_id: current_user.id, user_name: current_user.full_name)
  end

  def create_follow_up
  end

  def update_follow_up
  end
end
