# Copyright © 2011-2020 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

class ParticipantsController < ApplicationController
  before_action :find_protocol, only: [:index, :new, :show, :update_arm, :update_external_id, :update_status, :update_recruitment_source, :protocols_participants_in_protocol, :edit_arm, :edit_external_id, :update_protocol_association, :search]
  before_action :find_participant, only: [:show, :update_status, :update_recruitment_source, :details, :edit, :update, :destroy, :edit_arm, :edit_external_id, :update_arm, :update_external_id, :update_protocol_association, :patient_registry_modal_details]
  before_action :find_protocols_participant, only: [:show, :update_status, :update_recruitment_source, :edit_arm, :edit_external_id, :update_arm, :update_external_id, :update_protocol_association, :assign_arm_if_only_one_arm]
  before_action :note_old_protocols_participant_attributes, only: [:update_status, :update_recruitment_source, :update_arm, :update_external_id]
  before_action :authorize_protocol, only: [:show]
  before_action :authorize_patient_registrar, only: [:index]
  before_action :format_participant_name, only: [:create, :update]

  def index
    respond_to do |format|
      format.html
      format.json {
        @participants = Participant.search(params[:search])
        @total        = @participants.length
        @participants = @participants.sorted(params[:sort], params[:order]).limit(params[:limit]).offset(params[:offset] || 0)
      }
    end

    @page = params[:page]
    @status = params[:status] || 'all'
    @offset = params[:offset] || 0
    @limit = params[:limit] || 25

    @sort = determine_patient_sort

    respond_to do |format|
      format.html
      format.json
    end
  end

  def show
    @protocols_participant.build_appointments
    gon.push({appointment_id: params[:appointment_id]})
  end

  def new
    respond_to :js
    @participant = Participant.new unless @protocol.present?
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
    @participant.destroy
    flash[:alert] = t(:participant)[:flash_messages][:removed]
  end

  def format_participant_name
    params[:participant][:first_name] = params[:participant][:first_name].upcase.squish
    params[:participant][:last_name] = params[:participant][:last_name].upcase.squish
    params[:participant][:middle_initial] = params[:participant][:middle_initial].upcase.squish
  end

  def find_participants(action_name)
    @participants = Participant.search(params[:search])
    @total = @participants.count
    @participants = @participants.order(Arel.sql("#{@sort}")) if @sort
    @participants = @participants.limit(@limit).offset(@offset)
  end

  def update_protocol_association
    if params[:checked] == 'true'
      @protocols_participant = ProtocolsParticipant.new(protocol_id: @protocol.id, participant_id: @participant.id)
      assign_arm_if_only_one_arm
      if @protocols_participant.valid?
        @protocols_participant.save
        flash[:success] = t(:participant)[:flash_messages][:added_to_protocol]
      end
    else
      @protocols_participant.destroy
      flash[:success] = t(:participant)[:flash_messages][:removed_from_protocol]
    end
  end

  def search
    find_participants(action_name)
    respond_to do |format|
      format.html
      format.json
    end
  end

  def update_external_id
    @protocols_participant.update_attributes(protocols_participant_params)
    @protocols_participant.update_appointments_on_arm_change
    note_successful_changes
    flash[:success] = t(:participant)[:flash_messages][:updated]
  end

  def update_status
    if @protocols_participant.update_attributes(protocols_participant_params)
      note_successful_changes
      flash[:success] = t(:participant)[:flash_messages][:updated]
    else
      @errors = @participant.errors
    end
  end

  def update_recruitment_source
    if @protocols_participant.update_attributes(protocols_participant_params)
      note_successful_changes
      flash[:success] = t(:participant)[:flash_messages][:updated]
    else
      @errors = @participant.errors
    end
  end

  def update_arm
    @protocols_participant.update_attributes(protocols_participant_params)
    @protocols_participant.update_appointments_on_arm_change
    note_successful_changes

    flash[:success] = t(:participant)[:flash_messages][:arm_change]
  end

  def protocols_participants_in_protocol
    @page = params[:page]
    @status = params[:status] || 'all'
    @offset = params[:offset] || 0
    @limit = params[:limit] || 10

    @sort = determine_patient_sort
    find_participants(action_name)

    respond_to do |format|
      format.json {
        render
      }
    end
  end

  private

  def authorize_patient_registrar
    unless current_identity.is_a_patient_registrar?
      flash[:alert] = t(:protocol)[:flash_messages][:unauthorized]
      redirect_to root_path
    end
  end

  def determine_patient_sort
    if params[:order]
      order = params[:order] || 'asc'
    end

    @sort =
      case params[:sort]
      when 'last_name'
        "participants.last_name #{order}"
      when 'first_middle'
         "participants.first_name #{order}"
      when 'mrn'
        "participants.mrn #{order}"
      else
        "#{params[:sort]} #{order}"
      end
  end

  def find_protocol
    @protocol = Protocol.find(params[:protocol_id]) if params[:protocol_id]
  end

  def find_protocols_participant
    where_clause = params[:protocols_participant_id].present? ? "id = #{params[:protocols_participant_id]}" : "protocols_participants.protocol_id = #{@protocol.id} AND protocols_participants.participant_id = #{@participant.id}"
    @protocols_participant = ProtocolsParticipant.where(where_clause).first
  end

  def participant_params
    params.require(:participant).permit(:last_name, :first_name, :middle_initial, :mrn,:date_of_birth, :gender, :ethnicity, :race, :address, :city, :state, :zipcode, :phone, :deidentified)
  end

  def protocols_participant_params
    params.require(:protocols_participant).permit(:protocol_id, :participant_id, :arm_id, :status, :recruitment_source, :external_id)
  end

  def find_participant
    participant_id = params[:id] || params[:participant_id]
    @participant = Participant.where(id: participant_id).first

    if !@participant.present?
      flash[:alert] = t(:participant)[:flash_messages][:not_found]
      redirect_to root_path
    end
  end

  def assign_arm_if_only_one_arm
    if @protocol.arms.size == 1
      @protocols_participant.update_attributes(arm_id: @protocol.arms.first.id)
      @protocols_participant.update_appointments_on_arm_change
    end
  end

  def note_old_protocols_participant_attributes
    @old_attributes = @protocols_participant.attributes
  end

  def note_successful_changes
    if protocols_participant_params[:status] and ( @old_attributes["status"] != protocols_participant_params[:status] ) # Status Changed
      old_status = @old_attributes["status"].blank? ? t(:actions)[:n_a] : @old_attributes["status"]
      new_status = protocols_participant_params[:status].blank? ? t(:actions)[:n_a] : protocols_participant_params[:status]
      @participant.notes.create(identity: current_identity, comment: "Status changed from #{old_status} to #{new_status}")
    end

    if protocols_participant_params[:arm_id] and ( @old_attributes["arm_id"].to_s != protocols_participant_params[:arm_id] ) # Arm Changed
      old_arm = @old_attributes["arm_id"].blank? ? t(:actions)[:n_a] : Arm.find(@old_attributes["arm_id"]).name
      new_arm = protocols_participant_params[:arm_id].blank? ? t(:actions)[:n_a] : Arm.find(protocols_participant_params[:arm_id]).name
      @participant.notes.create(identity: current_identity, comment: "Arm changed from #{old_arm} to #{new_arm}")
    end
  end

  def set_highlighted_link
    @highlighted_link ||= 'participants'
  end
end
