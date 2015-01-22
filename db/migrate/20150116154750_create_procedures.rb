class CreateProcedures < ActiveRecord::Migration
  def change
    create_table :procedures do |t|
      t.integer :appointment_id
      t.string :service_name
      t.integer :service_cost
      t.integer :service_id
      t.string :status
      t.datetime :start_date
      t.datetime :completed_date
      t.string :billing_type
      t.string :reason
      t.datetime :follow_up_date
      t.integer :sparc_core_id
      t.string :sparc_core_name
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
