class AddParticipantsIndicies < ActiveRecord::Migration
  def change
    add_index "participants", ["protocol_id"], name: "index_participants_on_protocol_id", using: :btree
    add_index "participants", ["arm_id"], name: "index_participants_on_arm_id", using: :btree
  end
end
