module AppointmentHelper

  def historical_statuses statuses
    old_statuses = []
    statuses.each do |status|
      unless Appointment::STATUSES.include? status
        old_statuses << status
      end
    end

    old_statuses
  end

  def app_add_as_last_option appointment
    content_tag(:option, "Add as last", value: appointment.arm.appointments.where(participant_id: appointment.participant_id).last.position + 1)
  end
end
