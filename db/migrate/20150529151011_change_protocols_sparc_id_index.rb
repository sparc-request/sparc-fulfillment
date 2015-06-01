class ChangeProtocolsSparcIdIndex < ActiveRecord::Migration
  def up
    remove_index "protocols", name: "index_protocols_on_sparc_id"
    add_index "protocols", ["sparc_id"], name: "index_protocols_on_sparc_id", using: :btree
  end

  def down
    remove_index "protocols", name: "index_protocols_on_sparc_id"
    add_index "protocols", ["sparc_id"], name: "index_protocols_on_sparc_id", unique: true, using: :btree
  end
end
