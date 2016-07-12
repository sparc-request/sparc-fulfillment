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
    #Remove custom procedures from appointment
    @appointment.procedures.where(visit_id: nil).each{|proc| proc.destroy_regardless_of_status}
    #Reset all procedures under appointment
    @appointment.procedures.each{|procedure| procedure.reset}

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
