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
end