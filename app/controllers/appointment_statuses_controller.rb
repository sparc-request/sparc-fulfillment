class AppointmentStatusesController < ApplicationController

  respond_to :json, :html

  def change_statuses
    @appointment = Appointment.find(params[:appointment_id])
    previous_statuses = @appointment.appointment_statuses.map{|x| x.status}
    current_statuses = get_current_statuses(params[:statuses])

    if previous_statuses.size > current_statuses.size
      to_destroy = previous_statuses - current_statuses
      destroy(to_destroy.first)
    elsif previous_statuses.size < current_statuses.size
      to_create = current_statuses - previous_statuses
      create(to_create.first)
    end
  end

  private

  def create status
    AppointmentStatus.create(appointment_id: @appointment.id, status: status)
  end

  def destroy status
    @appointment.appointment_statuses.where(status: status).first.destroy
  end

  def get_current_statuses statuses
    if statuses == ""
      return []
    else
      return statuses
    end
  end
end