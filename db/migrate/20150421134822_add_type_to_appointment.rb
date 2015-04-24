class AddTypeToAppointment < ActiveRecord::Migration
  def change
    add_column :appointments, :type, :string, :default => "Appointment"
    add_index :appointments, :type
  end
end
