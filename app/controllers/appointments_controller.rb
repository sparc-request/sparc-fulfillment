# Copyright © 2011-2019 MUSC Foundation for Research Development~
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

  respond_to :json, :html

  #### BEGIN CUSTOM APPOINTMENTS ####

  def new
    @appointment = CustomAppointment.new(custom_appointment_params)
    @note = @appointment.notes.new(kind: 'reason')
  end

  def create
    @appointment = CustomAppointment.new(custom_appointment_params)

    if @appointment.valid?
      @appointment.save
    end
  end

  #### END CUSTOM APPOINTMENTS ####

  def show
    @appointment = Appointment.find params[:id]
    @statuses = @appointment.appointment_statuses.map{|x| x.status}

    if @appointment.procedures.with_deleted.empty?
      @appointment.initialize_procedures
    end
  end

  def completed_appointments
    protocols_participant = ProtocolsParticipant.find(params[:protocols_participant_id])
    @appointments = protocols_participant.appointments.completed
    respond_with @appointments
  end

  def update
    @appointment = Appointment.find params[:id]
    @field = params[:field]

    @appointment.update_attributes(appointment_params)
  end

  def update_statuses
    @appointment = Appointment.find params[:appointment_id]
    new_statuses = params[:statuses]
    @appointment.appointment_statuses.destroy_all

    if params[:statuses].present?
      new_statuses.each do |status|
        @appointment.appointment_statuses.create(status: status)
      end
    end

    render body: nil
  end

  private

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
end
