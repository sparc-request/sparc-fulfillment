class RenameUserRolesTable < ActiveRecord::Migration
  def change
    rename_table :user_roles, :identity_roles
    rename_column :identity_roles, :user_id, :identity_id
  end
end
