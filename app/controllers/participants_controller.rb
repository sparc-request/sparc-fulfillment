class ParticipantsController < ApplicationController

  before_action :find_protocol, only: [:index, :new]
  before_action :find_participant, only: [:show, :edit, :update, :destroy]
  before_action :authorize_protocol, only: [:show]

  def index
    respond_to do |format|
      format.json {
        @participants = @protocol.participants

        render
      }
    end
  end

  def new
    respond_to do |format|
      format.js {
        @participant = Participant.new(protocol_id: params[:protocol_id])
      }
    end
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
    create_note_for_arm_change(params, @participant)
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

  def find_protocol
    @protocol = Protocol.find(params[:protocol_id])
  end

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

  def create_note_for_arm_change(params, participant)
    if participant.arm_id.to_s != params[:participant][:arm_id]
      current_arm_name = participant.arm.blank? ? "BLANK ARM" : participant.arm.name
      new_arm_name = params[:participant][:arm_id].blank? ? "BLANK ARM" : Arm.find(params[:participant][:arm_id]).name
      @note = Note.create(identity: current_identity, notable_type: 'Participant', notable_id: participant.id,
                          comment: "Arm changed from #{current_arm_name} to #{new_arm_name}")
    end
  end
end
