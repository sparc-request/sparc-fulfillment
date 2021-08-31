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

class ProceduresController < ApplicationController
  before_action :find_appointment, only: [:index, :create, :edit, :update, :destroy, :change_procedure_position]
  before_action :find_procedure, only: [:edit, :update, :destroy, :change_procedure_position]
  before_action :save_original_procedure_status, only: [:update]
  before_action :create_note_before_update, only: [:update]
  before_action :set_appointment_style, only: [:create, :index, :update, :destroy, :change_procedure_position]

  def index
    respond_to :json

    @procedures     = @appointment.procedures.eager_load(:notes, :task).preload(:service, :protocol).where(sparc_core_id: params[:core_id]).order(:position)
    @performable_by = @appointment.performable_by
  end

  def create
    qty           = params[:qty].to_i
    service       = Service.find_by(id: params[:service_id])
    performer_id  = params[:performer_id]

    new_procedure = Procedure.new(appointment: @appointment,
                                     service_id: service.try(:id),
                                     service_name: service.try(:name),
                                     performer_id: performer_id,
                                     billing_type: 'research_billing_qty',
                                     sparc_core_id: service.try(:sparc_core_id),
                                     sparc_core_name: service.try(:sparc_core_name))

    if new_procedure.valid?
      qty.times do
        new_procedure.dup.save
      end

      @statuses = @appointment.appointment_statuses.pluck(:status)
      render 'appointments/show'
    else
      @errors = new_procedure.errors
    end
  end

  def edit
    respond_to :js

    @task = Task.new
    @clinical_providers = ClinicalProvider.includes(:identity).where(organization_id: current_identity.protocols_organizations_ids).order('identities.last_name')
    if params[:partial].present?
      @note = @procedure.notes.new(kind: 'reason')
      render params[:partial]
    else
      render
    end
  end

  def update
    respond_to :js

    unless @procedure.update_attributes(procedure_params)
      @errors = @procedure.errors
    end

    @billing_type_updated = procedure_params.has_key?(:billing_type) #If billing type has changed, need to refresh groups if in grouped view
    @invoiced_or_credited_changed = change_in_invoiced_or_credited_detected?
    @statuses = @appointment.appointment_statuses.pluck(:status)
    @cost_error_message = @procedure.errors.messages[:service_cost].detect{|message| message == "No cost found, ensure that a valid pricing map exists for that date."}
  end

  def destroy
    respond_to :js

    @procedure.destroy
  end

  def change_procedure_position
    respond_to :js

    @movement_type = params[:movement_type]
    @core_id = @procedure.sparc_core_id

    @procedure.send("move_#{@movement_type}")
  end

  private

  def find_appointment
    @appointment = Appointment.find(params[:appointment_id])
  end

  def find_procedure
    @procedure = @appointment.procedures.find(params[:id])
  end

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

  def change_in_invoiced_or_credited_detected?
    invoiced_changed = procedure_params[:invoiced].present? && procedure_params[:invoiced] != @procedure.invoiced
    credited_changed = procedure_params[:credited].present? && procedure_params[:credited] != @procedure.credited
    return invoiced_changed || credited_changed
  end

  def procedure_params
    params.
      require(:procedure).
      permit(:status,
             :follow_up_date,
             :completed_date,
             :billing_type,
             :performer_id,
             :invoiced,
             :credited,
             notes_attributes: [:comment, :kind, :identity_id, :reason],
             tasks_attributes: [:assignee_id, :identity_id, :body, :due_at])
  end
end
