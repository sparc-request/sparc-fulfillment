class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :participant_name
      t.string :created_by
      t.integer :protocol_id
      t.string :visit_name
      t.string :arm_name
      t.string :task
      t.string :assignment
      t.date :due_date
      t.boolean :is_complete
    end
  end
end
