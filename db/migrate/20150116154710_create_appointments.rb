class CreateAppointments < ActiveRecord::Migration
  def change
    create_table :appointments do |t|
      t.integer :participant_id
      t.integer :visit_group_id
      t.integer :visit_group_position
      t.integer :position
      t.string :name
      t.datetime :start_date
      t.datetime :completed_date
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
