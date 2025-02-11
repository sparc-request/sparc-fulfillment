class CreateColumnPreferences < ActiveRecord::Migration[5.2]
  def change
    create_table :column_preferences do |t|
      t.references :identity, null: false
      t.string :column_name, null: false
      t.boolean :visible, null: false

      t.timestamps
    end
    add_index :column_preferences, [:identity_id, :column_name], unique: true

  end
end
