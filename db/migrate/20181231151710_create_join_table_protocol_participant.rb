class CreateJoinTableProtocolParticipant < ActiveRecord::Migration[5.2]
  def change
    create_join_table :protocols, :participants do |t|
      t.index [:protocol_id, :participant_id], :unique => true
    end
    participant_protocol_ids_collection = Participant.all.map{ |participant| [participant_id: participant.id, protocol_id: participant.protocol_id] }
    participant_protocol_ids_collection.each do |participant_protocol_ids|
      ids = participant_protocol_ids.first
      participant_id = ids[:participant_id]
      protocol_id = ids[:protocol_id]
      ParticipantsProtocol.create(participant_id: participant_id, protocol_id: protocol_id)
    end
  end
end