class MultipleProceduresController < ApplicationController
  #this controller exists to mass update the statuses of procedures (complete all, and incomplete all)
  def update_procedures
    procedures = Procedures.where(sparc_core_id: params[:core_id], appointment_id: params[:appointment_id])

    #now update all procedures with new status and create notes.
    ##
  end
end
