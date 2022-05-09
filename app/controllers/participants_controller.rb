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
  before_action :find_protocol, only: [:index, :new, :show, :update_arm, :update_external_id, :update_status, :update_recruitment_source, :protocols_participants_in_protocol, :edit_arm, :edit_external_id, :search]
  before_action :find_participant, only: [:show, :update_status, :update_recruitment_source, :details, :edit, :update, :destroy, :edit_arm, :edit_external_id, :update_arm, :update_external_id, :patient_registry_modal_details]
  before_action :find_protocols_participant, only: [:show, :update_status, :update_recruitment_source, :edit_arm, :edit_external_id, :update_arm, :update_external_id]
  before_action :authorize_protocol, only: [:show]
  before_action :format_participant_name, only: [:create, :update]

  def index
    respond_to do |format|
      format.html
      format.json {
        @participants = Participant.search(params[:search])
        @total        = @participants.count
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
    @participants = Participant.includes(:procedures).search(params[:search])
    @total = @participants.count
    @participants = @participants.order(Arel.sql("#{@sort}")) if @sort
    @participants = @participants.limit(@limit).offset(@offset)
  end

  def search
    find_participants(action_name)
    respond_to do |format|
      format.html
      format.json
    end
  end

  def details
    #This is here because I spent 3 hours trying to figure out how rails was rendering an action that didn't exist -.-
    #I don't care if it's "not needed" technically, it's a troubleshooting nightmare.
  end

  private


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

  def set_highlighted_link
    @highlighted_link ||= 'participants'
  end
end
