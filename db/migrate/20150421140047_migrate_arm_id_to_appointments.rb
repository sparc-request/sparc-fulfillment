class MigrateArmIdToAppointments < ActiveRecord::Migration
  def change
    Appointment.all.each do |appt|
      appt.update_attribute(:arm_id, appt.visit_group.arm_id)
    end
  end
end
