class RenameIdentityForeignKeys < ActiveRecord::Migration
  def change
    rename_column :notes, :user_id, :identity_id
    rename_column :tasks, :user_id, :identity_id
  end
end
