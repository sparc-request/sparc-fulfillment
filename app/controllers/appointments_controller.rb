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

  def completed_time
    @appointment = Appointment.find params[:id]
    date = show_time @appointment.completed_date
    hour = Time.strptime(params[:hour] + params[:meridian], "%I%P").strftime("%H")
    updated_date = date.change({hour: hour, min: params[:minute]})
    @appointment.update_attributes(completed_date: updated_date)
  end

  def completed_date
    @appointment = Appointment.find params[:id]
    updated_date = ''

    if not params[:date].blank?
      year, month, day = params[:date].split('-')
      updated_date = show_time @appointment.completed_date
      updated_date = updated_date.change({year: year, month: month, day: day})
    end

    @appointment.update_attributes(completed_date: updated_date)
  end

  def start_time
    @appointment = Appointment.find params[:id]
    date = show_time @appointment.start_date
    hour = Time.strptime(params[:hour] + params[:meridian], "%I%P").strftime("%H")
    updated_date = date.change({hour: hour, min: params[:minute]})
    @appointment.update_attributes(start_date: updated_date)
  end

  def start_date
    @appointment = Appointment.find params[:id]
    updated_date = ''

    if not params[:date].blank?
      year, month, day = params[:date].split('-')
      updated_date = show_time @appointment.start_date
      updated_date = updated_date.change({year: year, month: month, day: day})
    end

    @appointment.update_attributes(start_date: updated_date)
  end

  private

  def show_time in_time
    in_time.blank? ? Time.now : in_time
  end

end
