class AppointmentStatusesController < ApplicationController

  respond_to :json, :html

  def change_statuses
    @appointment = Appointment.find(params[:appointment_id])
    previous_statuses = @appointment.appointment_statuses
    current_statuses = params[:statuses]
    to_create = current_statuses - previous_statuses
    to_destroy = previous_statuses - current_statuses

    if to_create.size > to_destroy.size
      create(to_create.first)
    else
      destroy(to_destroy.first)
    end
  end

  private

  def create status
    AppointmentStatus.create(appointment_id: @appointment.id, status: status)
  end

  def destroy status
    @appointment.appointment_statuses.where(status: status).destroy
  end
end