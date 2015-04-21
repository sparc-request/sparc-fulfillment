class CustomAppointment < Appointment
  validates :participant_id, :name, :arm_id, presence: true

  def self.model_name
    Appointment.model_name
  end
end
