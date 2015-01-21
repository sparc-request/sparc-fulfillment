class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.integer :procedure_id
      t.integer :user_id
      t.string :user_name
      t.string :comment
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
