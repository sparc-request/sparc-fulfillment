class AddAppointmentIdToAppointmentStatuses < ActiveRecord::Migration
  def change
    add_column :appointment_statuses, :appointment_id, :integer
  end
end
