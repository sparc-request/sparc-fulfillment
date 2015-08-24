class MultipleProceduresController < ApplicationController
  #this controller exists to mass update the statuses of procedures (complete all, and incomplete all)

  def incomplete_all
    @core_id = params[:core_id]
    @appointment_id = params[:appointment_id]
    @note = Note.new(kind: 'reason')
  end

  def update_procedures
    @core_id = params[:core_id]
    @status = params[:status]
    @appointment = Appointment.find(params[:appointment_id])
    procedures = Procedure.where(sparc_core_id: @core_id, appointment_id: params[:appointment_id])

    if @status == "incomplete"
      #Create test note for validation.
      @note = Note.new(kind: 'reason', reason: params[:reason], notable_type: "Procedure")

      if @note.valid?
        #Now update all procedures with incomplete status and create notes.
        procedures.each do |procedure|
          procedure.update_attributes(status: "incomplete", performer_id: nil)
          procedure.notes.create(identity_id: current_identity.id, kind: 'reason', reason: params[:reason], comment: params[:comment])
        end
      end
    elsif @status == "complete"
      #Mark all procedures as complete.
      procedures.each{|procedure| procedure.update_attributes(status: "complete", performer_id: current_identity.id)}
      @completed_date = procedures.first.completed_date
    end
  end
end
