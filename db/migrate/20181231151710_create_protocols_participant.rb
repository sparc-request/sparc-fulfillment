class CreateProtocolsParticipant < ActiveRecord::Migration[5.2]
  def change
    create_table :protocols_participants do |t|
      t.index [:protocol_id, :participant_id], :unique => true
      t.references :protocol
      t.references :participant
      t.references :arm
      t.string :status
    end

    participant_protocol_ids_collection = Participant.all.map{ |participant| [participant_id: participant.id, protocol_id: participant.protocol_id, arm_id: participant.arm_id, status: participant.status] }
    
    participant_protocol_ids_collection.each do |participant_protocol_ids|
      ids = participant_protocol_ids.first
      participant_id = ids[:participant_id]
      protocol_id = ids[:protocol_id]
      arm_id = ids[:arm_id]
      status = ids[:status]
      ProtocolsParticipant.create(participant_id: participant_id, protocol_id: protocol_id,  arm_id: arm_id, status: status)
    end

    remove_column :participants, :protocol_id, :integer
    remove_column :participants, :arm_id, :integer
    remove_column :participants, :status, :string
  end
end