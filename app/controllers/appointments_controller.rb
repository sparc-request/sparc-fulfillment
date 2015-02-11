class AppointmentsController < ApplicationController

  def show
    @appointment = Appointment.find params[:id]

    if @appointment.procedures.empty?
      @appointment.initialize_procedures
    end
  end
end
