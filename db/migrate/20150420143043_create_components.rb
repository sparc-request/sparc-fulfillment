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
  end
end
