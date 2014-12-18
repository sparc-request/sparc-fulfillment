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
    @protocol = Protocol.find(params[:protocol_id])
    @participant = Participant.new(participant_params)
    @participant.protocol_id = @protocol.id
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
    @protocol = Protocol.find(params[:protocol_id])
    @participant = Participant.new(participant_params)
    @participant.protocol_id = @protocol.id
    if @participant.valid?
      @participant = Participant.find(params[:id])
      @participant.update(participant_params)
      flash[:success] = "Participant Saved"
    else
      @errors = @participant.errors
    end
  end

  def destroy
    @protocol = Protocol.find(params[:protocol_id])
    Participant.destroy(params[:id])
    flash[:alert] = "Participant Removed"
  end

  def edit_arm
    @protocol = Protocol.find(params[:protocol_id])
    @participant = Participant.find(params[:participant_id])
    if params[:id]
      @arm = Arm.find(params[:id])
      @path = "/protocols/#{@protocol.id}/participants/#{@participant.id}/change_arm/#{@arm.id}"
    else
      @arm = Arm.new
      @path = "/protocols/#{@protocol.id}/participants/#{@participant.id}/change_arm"
    end
  end

  def update_arm
    @protocol = Protocol.find(params[:protocol_id])
    @participant = Participant.find(params[:participant_id])
    if params[:arm][:name] == ""
      @participant.arm = nil
    else
      @participant.arm = Arm.find( @protocol.arms.select{ |a| a.name == params[:arm][:name]}[0].id )
    end
    @participant.save
    flash[:success] = "Participant Successfully Changed Arms"
  end

  private

  def participant_params
    params.require(:participant).permit(:last_name, :first_name, :mrn, :status, :date_of_birth, :gender, :ethnicity, :race, :address, :phone)
  end


end
