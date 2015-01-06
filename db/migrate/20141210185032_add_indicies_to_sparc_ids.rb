class AddIndiciesToSparcIds < ActiveRecord::Migration
  def change
    add_index "arms", ["sparc_id"], name: "index_arms_on_sparc_id", unique: true, using: :btree
    add_index "line_items", ["sparc_id"], name: "index_line_items_on_sparc_id", unique: true, using: :btree
    add_index "protocols", ["sparc_id"], name: "index_protocols_on_sparc_id", unique: true, using: :btree
    add_index "services", ["sparc_id"], name: "index_services_on_sparc_id", unique: true, using: :btree
    add_index "visit_groups", ["sparc_id"], name: "index_visit_groups_on_sparc_id", unique: true, using: :btree
    add_index "visits", ["sparc_id"], name: "index_visits_on_sparc_id", unique: true, using: :btree
  end
end
