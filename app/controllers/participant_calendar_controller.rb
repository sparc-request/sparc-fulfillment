class ParticipantCalendarController < ApplicationController

  def complete_procedure
    @procedure = Procedure.find(params[:procedure_id])
    @procedure.update_attributes(status: "complete", completed_date: Time.now)
    Note.create(procedure_id: @procedure.id, user_id: current_user.id, user_name: current_user.full_name, comment: "Set to completed")
  end

  def incomplete_procedure
  end

  def create_follow_up
  end

  def update_follow_up
  end

end
