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
    comment = params[:comment] == " " ? params[:reasons_selectpicker] : params[:reasons_selectpicker] + " - " + params[:comment]
    Note.create(procedure_id: @procedure.id, comment: comment, user_id: current_user.id, user_name: current_user.full_name)
  end

  def edit_follow_up
    @procedure = Procedure.find(params[:procedure_id])
    @note = Note.new
  end

  def update_follow_up
    @procedure = Procedure.find(params[:procedure_id])
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
