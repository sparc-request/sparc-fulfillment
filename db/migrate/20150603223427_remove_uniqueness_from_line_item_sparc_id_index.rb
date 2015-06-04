class RemoveUniquenessFromLineItemSparcIdIndex < ActiveRecord::Migration
  def change
    remove_index "line_items", name: "index_line_items_on_sparc_id"
    add_index "line_items", ["sparc_id"], name: "index_line_items_on_sparc_id", using: :btree
  end
end
