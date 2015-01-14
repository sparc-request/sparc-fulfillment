class AddIndiciesToActsAsParanoidModels < ActiveRecord::Migration
  def change
    add_index "arms", ["deleted_at"], name: "index_arms_on_deleted_at", using: :btree
    add_index "line_items", ["deleted_at"], name: "index_line_items_on_deleted_at", using: :btree
    add_index "participants", ["deleted_at"], name: "index_participants_on_deleted_at", using: :btree
    add_index "protocols", ["deleted_at"], name: "index_protocols_on_deleted_at", using: :btree
    add_index "services", ["deleted_at"], name: "index_services_on_deleted_at", using: :btree
    add_index "visit_groups", ["deleted_at"], name: "index_visit_groups_on_deleted_at", using: :btree
    add_index "visits", ["deleted_at"], name: "index_visits_on_deleted_at", using: :btree
  end
end
