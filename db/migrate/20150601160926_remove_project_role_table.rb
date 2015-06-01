class RemoveProjectRoleTable < ActiveRecord::Migration
  def change
    drop_table(:project_roles)
  end
end
