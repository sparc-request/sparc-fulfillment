class AddPositionIndexToVisitGroups < ActiveRecord::Migration
  def change
    add_index "visit_groups", ["position"], name: "index_visit_groups_on_position", using: :btree
  end
end
