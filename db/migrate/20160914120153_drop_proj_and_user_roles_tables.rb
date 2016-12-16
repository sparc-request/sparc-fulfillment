class DropProjAndUserRolesTables < ActiveRecord::Migration
  def change
    drop_table :project_roles
    drop_table :user_roles
  end
end
