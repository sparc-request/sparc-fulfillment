class AddSparcIdToParticipant < ActiveRecord::Migration
  def change
    add_column :participants, :sparc_id, :integer, :after => :id
    add_index "participants", ["sparc_id"], name: "index_participants_on_sparc_id", using: :btree
  end
end
