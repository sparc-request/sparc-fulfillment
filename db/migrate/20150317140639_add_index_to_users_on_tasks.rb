class AddIndexToUsersOnTasks < ActiveRecord::Migration
  def change
    add_index "tasks", ["user_id"], name: "index_tasks_on_user_id", using: :btree
  end
end
