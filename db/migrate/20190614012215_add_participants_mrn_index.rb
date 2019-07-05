class AddParticipantsMrnIndex < ActiveRecord::Migration[5.2]
  def change
    add_index "participants", ["mrn"], name: "index_participants_on_mrn", using: :btree
  end
end
