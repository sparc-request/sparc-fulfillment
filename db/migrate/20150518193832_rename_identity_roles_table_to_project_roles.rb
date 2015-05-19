class RenameIdentityRolesTableToProjectRoles < ActiveRecord::Migration
  def change
    rename_table :identity_roles, :project_roles
  end
end
