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

class MultipleProceduresController < ApplicationController

  before_action :find_procedures, only: [:complete_all, :incomplete_all, :update_procedures]
  before_action :create_note_before_update, only: [:update_procedures]

  def complete_all
    @procedure_ids = params[:procedure_ids]
  end

  def incomplete_all
    @note = Note.new(kind: 'reason')
  end

  def update_procedures
    @core_id = @procedures.first.sparc_core_id
    status = params[:status]
    if status == 'incomplete'
      @performed_by = params[:performed_by]
      @procedures.each do |procedure|
        procedure.update_attributes(status: "incomplete", performer_id: @performed_by)
      end
    elsif status == 'complete'
      #Mark all @procedures as complete.
      @performed_by = params[:performed_by]
      @procedures.each{|procedure| procedure.update_attributes(status: 'complete', performer_id: @performed_by, completed_date: params[:completed_date])}
      @completed_date = params[:completed_date]
    end
  end

  def reset_procedures
    @appointment = Appointment.find(params[:appointment_id])
    #Status is used by the 'show' re-render
    @statuses = @appointment.appointment_statuses.map{|x| x.status}

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
    @appointment.initialize_procedures

    @refresh_dashboard = true

    render 'appointments/show'
  end

  private

  def find_procedures
    @procedures = Procedure.where(id: params[:procedure_ids])
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
