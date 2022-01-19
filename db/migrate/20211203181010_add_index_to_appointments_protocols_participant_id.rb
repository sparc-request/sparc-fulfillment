class AddIndexToAppointmentsProtocolsParticipantId < ActiveRecord::Migration[5.2]
  def change
    add_index "appointments", "protocols_participant_id", name: "index_appointments_on_protocols_participant_id", using: :btree
  end
end
