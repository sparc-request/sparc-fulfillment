class AddPolymorphicColumnsToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :assignable_type, :string
    add_column :tasks, :assignable_id, :integer
    add_column :tasks, :body, :text

    rename_column :tasks, :is_complete, :complete
    rename_column :tasks, :due_date, :due_at

    change_column :tasks, :complete, :boolean, default: false

    remove_column :tasks, :participant_name, :string
    remove_column :tasks, :protocol_id, :integer
    remove_column :tasks, :arm_name, :string
    remove_column :tasks, :task, :string
    remove_column :tasks, :task_type, :string
    remove_column :tasks, :visit_name, :string

    add_index "tasks", ["assignee_id"], name: "index_tasks_on_assignee_id", using: :btree
    add_index "tasks", ["assignable_id", "assignable_type"], name: "index_tasks_on_assignable_id_and_assignable_type", using: :btree
  end
end
