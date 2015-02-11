class ParticipantCalendarController < ApplicationController

  def complete_procedure
    @procedure = Procedure.find(params[:procedure_id])
    @procedure.update_attributes(status: "complete")
    puts current_user.inspect
    Note.create(procedure_id: @procedure.id, user_id: current_user.id, comment: "Set to completed")
  end

  def incomplete_procedure
  end

  def create_follow_up
  end

  def update_follow_up
  end

end
