class AddProtocolsParticipantsIdToAppointments < ActiveRecord::Migration[5.2]
  def change
    add_column :appointments, :protocols_participant_id, :integer
    bad_data = []
    appointment_data = Appointment.all.map{ |appointment| [appointment_id: appointment.id, participant_id: appointment.participant_id, arm_id: appointment.arm_id] }

    appointment_data.each do |data|
      data = data.first
      if ProtocolsParticipant.where(participant_id: data[:participant_id], arm_id: data[:arm_id]).empty?
        bad_data << data[:appointment_id]
      else
        Appointment.where(id: data[:appointment_id]).first.update_attributes(protocols_participant_id: (ProtocolsParticipant.where(participant_id: data[:participant_id], arm_id: data[:arm_id])).first.id)
      end
    end



    # Appointment.all.each do |appointment|
    #   if ProtocolsParticipant.where(participant_id: appointment.participant_id, arm_id: appointment.arm_id).empty?
    #     bad_data << appointment.id
    #   else
    #     appointment.update_attributes(protocols_participants_id: (ProtocolsParticipant.where(participant_id: appointment.participant_id, arm_id: appointment.arm_id)).first.id)
    #   end
    # end
    puts "Appointments with no matches: #{bad_data}"
    puts "*Number of Appointments with no matches: #{bad_data.count}"
    puts "Number of Appointments with no matches: #{bad_data}.count"
  end
end