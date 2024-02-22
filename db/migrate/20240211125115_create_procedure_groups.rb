class CreateProcedureGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :procedure_groups do |t|
      t.integer :appointment_id
      t.integer :sparc_core_id
      t.datetime :start_time
      t.datetime :end_time

      t.timestamps
    end
    add_foreign_key :procedure_groups, :appointments
  end
end
