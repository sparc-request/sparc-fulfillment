class CreateProtocolsParticipant < ActiveRecord::Migration[5.2]
  def up
    create_table :protocols_participants do |t|
      t.index [:protocol_id, :participant_id]
      t.references :protocol
      t.references :participant
      t.references :arm
      t.integer :sparc_id
      t.string :status
      t.datetime :deleted_at
      t.timestamps
    end

    progress_bar = ProgressBar.new(Participant.count)
    Participant.all.each do |participant|
      ProtocolsParticipant.create(participant_id: participant.id, protocol_id: participant.protocol_id, arm_id: participant.arm_id, status: participant.status, sparc_id: participant.sparc_id)
      progress_bar.increment!
    end
  end
end