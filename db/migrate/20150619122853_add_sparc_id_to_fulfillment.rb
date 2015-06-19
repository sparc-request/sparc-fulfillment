class AddSparcIdToFulfillment < ActiveRecord::Migration
  def change
    add_column :fulfillments, :sparc_id, :integer, :after => :id
    add_index "fulfillments", ["sparc_id"], name: "index_fulfillments_on_sparc_id", using: :btree
  end
end
