class AddArmIdToAppointment < ActiveRecord::Migration
  def change
    add_column :appointments, :arm_id, :integer
    add_index :appointments, :arm_id
  end

end
