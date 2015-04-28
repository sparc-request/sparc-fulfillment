class AddSparcIdToComponents < ActiveRecord::Migration
  def change
    add_column :components, :sparc_id, :integer

    add_index "components", "sparc_id", name: "index_components_on_sparc_id", using: :btree
  end
end
