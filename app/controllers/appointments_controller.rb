class AppointmentsController < ApplicationController
  respond_to :json, :html

  def show
    @appointment = Appointment.find params[:id]
    if @appointment.procedures.empty?
      @appointment.initialize_procedures
    end
  end

  def completed_appointments
    participant = Participant.find(params[:participant_id])
    @appointments = participant.appointments.completed
    respond_with @appointments
  end

  def start_date
    @appointment = Appointment.find params[:id]
    if params[:new_date]
      updated_date = Time.at(params[:new_date].to_i / 1000)
    else
      updated_date = Time.current
    end

    @appointment.update_attributes(start_date: updated_date)
  end

  def completed_date
    @appointment = Appointment.find params[:id]
    if params[:new_date]
      updated_date = Time.at(params[:new_date].to_i / 1000)
    else
      updated_date = Time.current
    end

    @appointment.update_attributes(completed_date: updated_date)
  end

  private

  def show_time in_time
    in_time.blank? ? Time.now : in_time
  end

end
