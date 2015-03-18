class AddIdsToTasks < ActiveRecord::Migration
  def change
    remove_column :tasks, :created_by, :string
    remove_column :tasks, :assignment, :string
    add_column :tasks, :user_id, :integer
    add_column :tasks, :assignee_id, :integer 
  end
end
