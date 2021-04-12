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

class MultipleProceduresController < ApplicationController
  before_action :find_appointment
  before_action :find_procedures, only: [:update_procedures]
  before_action :assign_multiple_procedure_errors, only: [:update_procedures]

  def complete_all
    # TODO: check if invoiced procedures/procedure groups can still be edited
    # This was the en.yml message that got removed: procedure_group_invoiced_warning:  "This group of procedures have been invoiced and cannot be altered."
    @procedure_ids = params[:procedure_ids]
    @performable_by = @appointment.performable_by
  end

  def incomplete_all
    @procedure_ids = params[:procedure_ids]
    @performable_by = @appointment.performable_by
    @note = Note.new(kind: 'reason')
  end

  def update_procedures
    unless @multiple_procedure_errors
      status = params[:status]
      create_note_before_update
      @procedures.each do |procedure|
        procedure.update_attributes(status: status, performer_id: params[:performer_id], completed_date: params[:completed_date])
      end
    end
  end

  def reset_procedures
    #Status is used by the 'show' re-render
    @statuses = @appointment.appointment_statuses.pluck(:status)

    #Reset parent appointment
    @appointment.update_attributes(start_date: nil, completed_date: nil)

    #Reset all procedures under appointment so they can be destroyed
    @appointment.procedures.each{|procedure| procedure.reset}
    #Destroy all procedures
    @appointment.procedures.each do |procedure|
      procedure.destroy
    end

    #Reload appointment to grab any calendar changes, then initialize procedures
    @appointment.reload
    procedure_creator = ProcedureCreator.new(@appointment)
    procedure_creator.initialize_procedures

    @refresh_dashboard = true

    render 'appointments/show'
  end

  private

  def find_appointment
    @appointment = Appointment.find(params[:appointment_id])
  end

  def find_procedures
    @procedures = @appointment.procedures.find(params[:procedure_ids])
  end

  def assign_multiple_procedure_errors
    # Assign errors here, can't use ActiveModel::Errors since there's no multiple_procedures model
    # and there is no nested form for notes
    @multiple_procedure_errors = {}
    @multiple_procedure_errors.store(:performer_id, t('multiple_procedures_modal.errors.performer_id')) if params[:performer_id].blank?
    @multiple_procedure_errors.store(:completed_date, t('multiple_procedures_modal.errors.completed_date')) if complete_status_detected? && params[:completed_date].blank?
    @multiple_procedure_errors.store(:reason, t('multiple_procedures_modal.errors.reason')) if incomplete_status_detected? && params[:reason].blank?
    @multiple_procedure_errors.store(:comment, t('multiple_procedures_modal.errors.comment')) if incomplete_status_detected? && params[:comment].blank?

    if @multiple_procedure_errors.empty?
      @multiple_procedure_errors = nil
    end
  end

  def create_note_before_update
    if reset_status_detected?
      @procedures.each do |procedure|
        procedure.notes.create(identity: current_identity,
                                comment: 'Status reset',
                                kind: 'log')
      end
    elsif incomplete_status_detected?
      @procedures.each do |procedure|
        procedure.notes.create(identity: current_identity,
                              comment: 'Status set to incomplete',
                              kind: 'log')
        procedure.notes.create(identity: current_identity,
                                comment: params[:comment],
                                kind: 'reason',
                                reason: params[:reason])
      end
    elsif change_in_completed_date_detected?
      @procedures.each do |procedure|
        procedure.notes.create(identity: current_identity,
                                comment: "Completed date updated to #{params[:completed_date]} ",
                                kind: 'log')
      end
    elsif complete_status_detected?
      @procedures.each do |procedure|
        procedure.notes.create(identity: current_identity,
                                comment: 'Status set to complete',
                                kind: 'log')
      end
    elsif change_in_performer_detected?
      new_performer = Identity.find(params[:performed_by])
      @procedures.each do |procedure|
        procedure.notes.create(identity: current_identity,
                                comment: "Performer changed to #{new_performer.full_name}",
                                kind: 'log')
      end
    end
  end

  def change_in_completed_date_detected?
    if params[:completed_date]
      Time.strptime(params[:completed_date], "%m/%d/%Y") != @procedures.first.completed_date
    else
      return false
    end
  end

  def reset_status_detected?
    params[:status] == "unstarted"
  end

  def incomplete_status_detected?
    params[:status] == "incomplete"
  end

  def complete_status_detected?
    @original_procedure_status != "complete" && params[:status] == "complete"
  end

  def change_in_performer_detected?
    params[:performed_by].present? && params[:performed_by] != @procedures.first.performer_id
  end
end
