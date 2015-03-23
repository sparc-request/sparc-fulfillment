class ParticipantsController < ApplicationController
  respond_to :json, :html

  def index
    @protocol = Protocol.find(params[:protocol_id])
    @participants = @protocol.participants
    respond_with @participants
  end

  def new
    @protocol = Protocol.find(params[:protocol_id])
    @participant = Participant.new(protocol_id: params[:protocol_id])
  end

  def show
    @protocol = Protocol.find(params[:protocol_id])
    @participant = Participant.find(params[:id])
    @participant.build_appointments
  end

  def create
    @protocol = Protocol.find(params[:protocol_id])
    @participant = Participant.new(participant_params)
    @participant.protocol_id = @protocol.id
    if @participant.valid?
      @participant.save
      flash[:success] = t(:flash_messages)[:participant][:created]
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
      flash[:success] = t(:flash_messages)[:participant][:saved]
    else
      @errors = @participant.errors
    end
  end

  def destroy
    @protocol = Protocol.find(params[:protocol_id])
    Participant.destroy(params[:id])
    flash[:alert] = t(:flash_messages)[:participant][:removed]
  end

  def edit_arm
    @protocol = Protocol.find(params[:protocol_id])
    @participant = Participant.find(params[:participant_id])
  end

  def update_arm
    @protocol = Protocol.find(params[:protocol_id])
    participant = Participant.find(params[:participant_id])
    participant.update_attributes(arm_id: params[:participant][:arm_id])
    participant.update_appointments_on_arm_change
    flash[:success] = t(:flash_messages)[:participant][:arm_change]
  end

  def details
    @participant = Participant.find(params[:participant_id])
  end

  def set_recruitment_source
    source = params[:source] == "" ? nil : params[:source]
    @participant = Participant.find(params[:participant_id])
    @participant.update_attributes(recruitment_source: source)
    flash[:success] = t(:flash_messages)[:participant][:recruitment_source]
  end

  private

  def participant_params
    params.require(:participant).permit(:last_name, :first_name, :middle_initial, :mrn, :external_id, :status, :date_of_birth, :gender, :ethnicity, :race, :address, :city, :state, :zipcode, :phone, :recruitment_source)
  end


end
