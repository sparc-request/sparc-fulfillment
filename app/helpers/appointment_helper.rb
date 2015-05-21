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

  def format_name appointment
    if appointment.visit_group
      return appointment.visit_group.name
    else
      return appointment.name
    end
  end
end