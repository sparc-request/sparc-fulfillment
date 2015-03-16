class AddPolymorphicToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :notable_id, :integer
    add_column :notes, :notable_type, :string

    remove_column :notes, :procedure_id, :integer
    remove_column :notes, :user_name, :string

    add_index "notes", ["notable_id", "notable_type"], name: "index_notes_on_notable_id_and_notable_type", using: :btree
    add_index "notes", ["user_id"], name: "index_notes_on_user_id", using: :btree
  end
end
