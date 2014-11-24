class ParticipantsController < ApplicationController

  def create
    puts "<*>"*1000
    puts params.inspect
    @participant = Participant.new(participant_params)
    @participant.save
  end

  private

  def participant_params
    params.require(:participant).permit(:last_name, :first_name, :mrn, :status, :date_of_birth, :gender, :ethnicity, :race, :address, :phone, :protocol_id)
  end
end
