class AddIndexOnArmsProtocolId < ActiveRecord::Migration
  def change
    add_index "arms", ["protocol_id"], name: "index_arms_on_protocol_id", using: :btree
  end
end
