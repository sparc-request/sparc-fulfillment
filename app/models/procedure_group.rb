# This class represents each group of a participant's procedures within an appointment that share the same Core ID (Sparcdb::Organization.id).
# It is used to track start and end times for participant visits. (https://www.pivotaltracker.com/story/show/186301263)

class ProcedureGroup < ApplicationRecord
  belongs_to :appointment
  has_one :protocols_participant, through: :appointment

  validates :appointment, presence: true
  validates :sparc_core_id, uniqueness: { scope: :appointment_id, message: "There should only be one procedure group per Core" }

  def set_start_time(time)
    unless time.blank?
      time_in_zone = DateTime.current.in_time_zone(ENV.fetch('APPLICATION_TIME_ZONE')).change(hour: Time.parse(time).hour, min: Time.parse(time).min)
      self.start_time = time_in_zone.utc
    end
  end

  def set_end_time(time)
    unless time.blank?
      time_in_zone = DateTime.current.in_time_zone(ENV.fetch('APPLICATION_TIME_ZONE')).change(hour: Time.parse(time).hour, min: Time.parse(time).min)
      self.end_time = time_in_zone.utc
    end
  end
end
