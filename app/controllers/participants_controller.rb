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
    if @participant.valid?
      @participant.save
      flash[:success] = "Participant Created"
    else
      @errors = @participant.errors
    end
  end

  def edit
    @protocol = Protocol.find(params[:protocol_id])
    @participant = Participant.find(params[:id])
  end

  def update
    @participant = Participant.new(participant_params)
    @participant.protocol_id = params[:protocol_id]
    if @participant.valid?
      @participant = Participant.find(params[:id])
      @participant.update(participant_params)
      flash[:success] = "Participant Saved"
    else
      @errors = @participant.errors
    end
  end

  def destroy
    Participant.destroy(params[:id])
    flash[:alert] = "Participant Removed"
  end

  private

  def participant_params
    params.require(:participant).permit(:last_name, :first_name, :mrn, :status, :date_of_birth, :gender, :ethnicity, :race, :address, :phone)
  end


end
