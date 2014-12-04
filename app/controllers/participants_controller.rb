class ParticipantsController < ApplicationController
  respond_to :json, :html

  def index
    @protocol = Protocol.find(params[:protocol_id])
    respond_with @protocol.participants
  end

  def new
    @protocol = Protocol.find(params[:protocol_id])
    @participant = Participant.new(protocol_id: params[:protocol_id])
  end

  def create
    @participant = Participant.new(participant_params)
    @participant.protocol_id = params[:protocol_id]
    @participant.save
    flash[:success] = "Participant Created"
  end

  def edit
    @protocol = Protocol.find(params[:protocol_id])
    @participant = Participant.find(params[:id])
    flash[:success] = "Participant Saved"
  end

  def update
    @participant = Participant.find(params[:id])
    @participant.update(participant_params)
  end

  def destroy
    Participant.destroy(params[:id])
    flash[:success] = "Participant Destroyed"
  end

  private

  def participant_params
    params.require(:participant).permit(:last_name, :first_name, :mrn, :status, :date_of_birth, :gender, :ethnicity, :race, :address, :phone)
  end


end
