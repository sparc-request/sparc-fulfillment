# Copyright © 2011-2023 MUSC Foundation for Research Development~
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

class AppointmentsController < ApplicationController
  respond_to :json, :html, :js
  before_action :find_appointment, only: [:show, :update, :update_statuses, :change_visit_type]
  before_action :set_appointment_style, only: [:create, :show, :update]

  def index
  end

  def show
    procedure_creator = ProcedureCreator.new(@appointment)

    if @appointment.procedures.with_deleted.empty?
      procedure_creator.initialize_procedures
    end
  end

  #### BEGIN CUSTOM APPOINTMENTS ####

  def new
    @appointment = CustomAppointment.new(protocols_participant_id: params[:protocols_participant_id], arm_id: params[:arm_id])
    @note = @appointment.notes.new(kind: 'reason')
  end

  def create
    @appointment = CustomAppointment.new(custom_appointment_params)
    @protocols_participant = ProtocolsParticipant.find(custom_appointment_params[:protocols_participant_id])
    if @appointment.valid?
      @appointment.save
    else
      @errors = @appointment.errors
    end
  end

  #### END CUSTOM APPOINTMENTS ####

  def completed_appointments
    protocols_participant = ProtocolsParticipant.find(params[:protocols_participant_id])
    @appointments = protocols_participant.appointments.completed
    respond_with @appointments
  end

  def update
    @field = params[:field]

    @appointment.update_attributes(appointment_params)

    if(!@appointment.valid?)
      @errors = @appointment.errors
    end

  end

  def update_statuses
    respond_to :js

    if(params[:statuses])
      @appointment.appointment_statuses.where.not(status: params[:statuses]).destroy_all
      (params[:statuses] - @appointment.appointment_statuses.pluck(:status)).each do |status|
        @appointment.appointment_statuses.create(status: status)
      end
    else
      @appointment.appointment_statuses.destroy_all
    end

    render body: nil
  end

  def change_visit_type
    @appointment.update_attributes(appointment_type_params)
  end

  def change_appointment_style
    respond_to :js

    @appointment_style = params[:appointment_style]
    session[:appointment_style] = @appointment_style

    @appointment = Appointment.find params[:appointment_id]
    @statuses = @appointment.appointment_statuses.pluck(:status)
  end

  def reset_procedures
  end

  private

  def find_appointment
    @appointment = Appointment.find(params[:id])
  end

  def show_time in_time
    in_time.blank? ? Time.now : in_time
  end

  def appointment_params
    params.require(:appointment).permit(:contents, :start_date, :completed_date)
  end

  def custom_appointment_params
    params.require(:custom_appointment)
          .permit(:arm_id, :protocols_participant_id, :name, :position,
                 notes_attributes: [:comment, :kind, :identity_id, :reason])
  end

  def appointment_type_params
    if(@appointment.type == 'CustomAppointment')
      params.require(:custom_appointment).permit(:contents, :start_date, :completed_date)
    else
      params.require(:appointment).permit(:contents, :start_date, :completed_date)
    end
  end


end
