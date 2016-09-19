# Copyright © 2011-2016 MUSC Foundation for Research Development~
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

class ProceduresController < ApplicationController

  before_action :find_procedure, only: [:edit, :update, :destroy]
  before_action :save_original_procedure_status, only: [:update]
  before_action :create_note_before_update, only: [:update]

  def create
    @appointment = Appointment.find params[:appointment_id]
    qty             = params[:qty].to_i
    service         = Service.find params[:service_id]
    performer_id    = params[:performer_id]
    @procedures     = []

    qty.times do
      @procedures << Procedure.create(appointment: @appointment,
                                      service_id: service.id,
                                      service_name: service.name,
                                      performer_id: performer_id,
                                      billing_type: 'research_billing_qty',
                                      sparc_core_id: service.sparc_core_id,
                                      sparc_core_name: service.sparc_core_name)
    end
  end

  def edit
    @task = Task.new
    if params[:partial].present?
      @note = @procedure.notes.new(kind: 'reason')
      render params[:partial]
    else
      @clinical_providers = ClinicalProvider.where(organization_id: current_identity.protocols.map{|p| p.sub_service_request.organization_id })
      render
    end
  end

  def update
    @procedure.update_attributes(procedure_params)
    @appointment = @procedure.appointment
    @statuses = @appointment.appointment_statuses.map{|x| x.status}
  end

  def destroy
    @procedure.destroy
  end

  private

  def save_original_procedure_status
    @original_procedure_status = @procedure.status
  end

  def create_note_before_update
    if reset_status_detected?
      @procedure.notes.create(identity: current_identity,
                              comment: 'Status reset',
                              kind: 'log')
    elsif incomplete_status_detected?
      @procedure.notes.create(identity: current_identity,
                              comment: 'Status set to incomplete',
                              kind: 'log')
    elsif change_in_completed_date_detected?
      @procedure.notes.create(identity: current_identity,
                              comment: "Completed date updated to #{procedure_params[:completed_date]} ",
                              kind: 'log')
    elsif complete_status_detected?
      @procedure.notes.create(identity: current_identity,
                              comment: 'Status set to complete',
                              kind: 'log')
    elsif change_in_performer_detected?
      new_performer = Identity.find(procedure_params[:performer_id])

      @procedure.notes.create(identity: current_identity,
                              comment: "Performer changed to #{new_performer.full_name}",
                              kind: 'log')
    end
  end

  def change_in_completed_date_detected?
    if procedure_params[:completed_date]
      Time.strptime(procedure_params[:completed_date], "%m/%d/%Y") != @procedure.completed_date
    else
      return false
    end
  end

  def reset_status_detected?
    procedure_params[:status] == "unstarted"
  end

  def incomplete_status_detected?
    procedure_params[:status] == "incomplete"
  end

  def complete_status_detected?
    @original_procedure_status != "complete" && procedure_params[:status] == "complete"
  end

  def change_in_performer_detected?
    procedure_params[:performer_id].present? && procedure_params[:performer_id] != @procedure.performer_id
  end

  def procedure_params
    params.
      require(:procedure).
      permit(:status,
             :follow_up_date,
             :completed_date,
             :billing_type,
             :performer_id,
             notes_attributes: [:comment, :kind, :identity_id, :reason],
             tasks_attributes: [:assignee_id, :identity_id, :body, :due_at])
  end

  def find_procedure
    @procedure = Procedure.find params[:id]
  end
end
