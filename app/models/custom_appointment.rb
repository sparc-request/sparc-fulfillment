class CustomAppointment < Appointment
  def self.model_name
    Appointment.model_name
  end
end
