class AppointmentsController < ApplicationController

  def show
    @appointment = Appointment.find params[:id]
    if @appointment.procedures.empty?
      @appointment.initialize_procedures
    end
  end

  def completed_appointments
    participant = Participant.find(params[:participant_id])
    puts participant.inspect
    puts participant.appointments.inspect
    @appointments = participant.appointments.where("completed_date IS NOT NULL")
    puts @appointments.inspect
  end

end
