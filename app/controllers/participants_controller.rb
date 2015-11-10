class ParticipantsController < ApplicationController

  before_action :find_protocol, only: [:index, :new]
  before_action :find_participant, only: [:show, :edit, :update, :destroy, :edit_arm, :update_arm, :details]
  before_action :note_old_participant_attributes, only: [:update, :update_arm]
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
        @participant = Participant.new(protocol_id: @protocol.id)
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
      note_successful_changes
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

  def update_arm
    @participant.update_attributes(arm_id: participant_params[:arm_id])
    @participant.update_appointments_on_arm_change
    note_successful_changes
    flash[:success] = t(:participant)[:flash_messages][:arm_change]
  end

  private

  def find_protocol
    @protocol = Protocol.find(params[:protocol_id])
  end

  def participant_params
    params.require(:participant).permit(:protocol_id, :arm_id, :last_name, :first_name, :middle_initial, :mrn, :external_id, :status, :date_of_birth, :gender, :ethnicity, :race, :address, :city, :state, :zipcode, :phone, :recruitment_source)
  end

  def find_participant
    participant_id = params[:id] || params[:participant_id]
    @participant = Participant.where(id: participant_id).first
    if @participant.present?
      @protocol = @participant.protocol
    else
      flash[:alert] = t(:participant)[:flash_messages][:not_found]
      redirect_to root_path
    end
  end

  def note_old_participant_attributes
    @old_attributes = @participant.attributes
  end

  def note_successful_changes
    if participant_params[:status] and ( @old_attributes["status"] != participant_params[:status] ) # Status Changed
      old_status = @old_attributes["status"].blank? ? t(:actions)[:n_a] : @old_attributes["status"]
      new_status = participant_params[:status].blank? ? t(:actions)[:n_a] : participant_params[:status]
      @participant.notes.create(identity: current_identity, comment: "Status changed from #{old_status} to #{new_status}")
    end

    if participant_params[:arm_id] and ( @old_attributes["arm_id"].to_s != participant_params[:arm_id] ) # Arm Changed
      old_arm = @old_attributes["arm_id"].blank? ? t(:actions)[:n_a] : Arm.find(@old_attributes["arm_id"]).name
      new_arm = participant_params[:arm_id].blank? ? t(:actions)[:n_a] : Arm.find(participant_params[:arm_id]).name
      @participant.notes.create(identity: current_identity, comment: "Arm changed from #{old_arm} to #{new_arm}")
    end
  end
end
