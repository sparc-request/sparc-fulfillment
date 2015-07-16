class MultipleProceduresController < ApplicationController
  #this controller exists to mass update the statuses of procedures (complete all, and incomplete all)

  def edit_procedures
    @core_id = params[:core_id]
    @appointment_id = params[:appointment_id]
    @note = Note.new(kind: 'reason') if params[:status] == "incomplete"
  end

  def incomplete_all
    @core_id = params[:core_id]
    procedures = Procedure.where(sparc_core_id: @core_id, appointment_id: params[:appointment_id])

    #Create test note for validation
    @note = Note.new(kind: 'reason', reason: params[:reason], notable_type: "Procedure")

    if @note.valid?
      #now update all procedures with new status and create notes.
      procedures.each do |procedure|
        procedure.update_attributes(status: "incomplete", performer_id: current_identity.id)
        procedure.notes.create(identity_id: current_identity.id, kind: 'reason', reason: params[:reason], comment: params[:comment])
      end
    end
  end

  def complete_all
    #Placeholder for "complete all" refactoring
  end
end
