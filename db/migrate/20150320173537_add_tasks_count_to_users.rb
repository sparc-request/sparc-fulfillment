class AddTasksCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :tasks_count, :integer, default: 0
  end
end
