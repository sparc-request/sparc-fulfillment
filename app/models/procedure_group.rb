# This class represents each group of a participant's procedures within an appointment that share the same Core ID (Sparcdb::Organization.id).
# It is used to track start and end times for participant visits. (https://www.pivotaltracker.com/story/show/186301263)

class ProcedureGroup < ApplicationRecord
  belongs_to :appointment

  validates :appointment, presence: true
  validates :sparc_core_id, uniqueness: { scope: :appointment_id, message: "There should only be one procedure group per Core" }
end

