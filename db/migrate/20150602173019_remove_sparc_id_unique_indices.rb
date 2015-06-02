class RemoveSparcIdUniqueIndices < ActiveRecord::Migration
  def change
    #arms
    remove_index "arms", name: "index_arms_on_sparc_id"
    add_index "arms", ["sparc_id"], name: "index_arms_on_sparc_id", using: :btree
    
    #visits
    remove_index "visits", name: "index_visits_on_sparc_id"
    add_index "visits", ["sparc_id"], name: "index_visits_on_sparc_id", using: :btree
    
    #visit_groups
    remove_index "visit_groups", name: "index_visit_groups_on_sparc_id"
    add_index "visit_groups", ["sparc_id"], name: "index_visit_groups_on_sparc_id", using: :btree
  end
end
