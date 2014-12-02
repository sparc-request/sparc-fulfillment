class ParticipantsController < ApplicationController
  respond_to :json, :html

  def index
    @protocol = Protocol.find(params[:protocol_id])
    respond_with @protocol.participants
  end

  def create
    @participant = Participant.new(participant_params)
    @participant.protocol_id = params[:protocol_id]
    @participant.save
  end

  private

  def participant_params
    params.require(:participant).permit(:last_name, :first_name, :mrn, :status, :date_of_birth, :gender, :ethnicity, :race, :address, :phone)
  end


end
