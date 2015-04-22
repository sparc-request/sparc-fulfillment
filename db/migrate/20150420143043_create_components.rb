class CreateComponents < ActiveRecord::Migration
  def change
    create_table :components do |t|
      t.string :component
      t.integer :position
      t.integer :composable_id
      t.string :composable_type
      t.boolean :selected, default: false
      t.timestamps
      t.timestamp :deleted_at
    end

    add_index "components", ["composable_id", "composable_type"], name: "index_components_on_composable_id_and_composable_type", using: :btree
  end
end
