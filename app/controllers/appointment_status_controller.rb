class AppointmentStatusesController < ApplicationController

  respond_to :json, :html

  def change_statuses
    appointment = Appointment.find(params[:appointment_id])
    previous_statuses = appointment.appointment_statuses
    current_statuses = params[:statuses]
    to_create = current_statuses - previous_statuses
    to_destroy = previous_statuses - current_statuses
  end

  private

  def create

  end

  def destroy

  end
end