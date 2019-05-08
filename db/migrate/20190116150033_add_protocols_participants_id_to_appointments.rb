class AddProtocolsParticipantsIdToAppointments < ActiveRecord::Migration[5.2]
  def up
    add_column :appointments, :protocols_participant_id, :integer
    Appointment.reset_column_information
    bad_data = []
    progress_bar = ProgressBar.new(Appointment.count)
    Appointment.find_each do |appt|
      if protocols_participant = ProtocolsParticipant.where(participant_id: appt.participant_id).first
        appt.update_attribute(:protocols_participant_id, protocols_participant.id)
      else
        bad_data << appt.id
      end
      progress_bar.increment!
    end
    puts "Appointments with no matches: #{bad_data}"
    puts "Number of Appointments with no matches: #{bad_data.count}"
  end
end
