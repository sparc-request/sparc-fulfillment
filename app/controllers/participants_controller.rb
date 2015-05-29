class ParticipantsController < ApplicationController
  respond_to :json, :html
  before_action :find_participant, only: [:show, :edit, :update, :destroy]
  before_action :authorize_protocol, only: [:show]

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
    @participant.build_appointments

    gon.push({appointment_id: params[:appointment_id]})
  end

  def create
    @participant = Participant.new(participant_params)
    if @participant.valid?
      @participant.save
      flash[:success] = t(:participant)[:flash_messages][:created]
    else
      @errors = @participant.errors
    end
  end

  def update
    if @participant.update_attributes(participant_params)
      flash[:success] = t(:participant)[:flash_messages][:updated]
    else
      @errors = @participant.errors
    end
  end

  def destroy
    @protocol_id = @participant.protocol_id
    @participant.destroy
    flash[:alert] = t(:participant)[:flash_messages][:removed]
  end

  def edit_arm
    @participant = Participant.find(params[:participant_id])
  end

  def update_arm
    @participant = Participant.find(params[:participant_id])
    @participant.update_attributes(arm_id: params[:participant][:arm_id])
    @participant.update_appointments_on_arm_change
    flash[:success] = t(:participant)[:flash_messages][:arm_change]
  end

  def details
    @participant = Participant.find(params[:participant_id])
  end

  def set_recruitment_source
    source = params[:source] == "" ? nil : params[:source]
    @participant = Participant.find(params[:participant_id])
    @participant.update_attributes(recruitment_source: source)
    flash[:success] = t(:participant)[:flash_messages][:recruitment_source]
  end

  private

  def participant_params
    params.require(:participant).permit(:protocol_id, :last_name, :first_name, :middle_initial, :mrn, :external_id, :status, :date_of_birth, :gender, :ethnicity, :race, :address, :city, :state, :zipcode, :phone, :recruitment_source)
  end

  def find_participant
    @participant = Participant.where(id: params[:id]).first
    if @participant.present?
      @protocol = @participant.protocol
    else
      flash[:alert] = t(:participant)[:flash_messages][:not_found]
      redirect_to root_path
    end
  end
end
