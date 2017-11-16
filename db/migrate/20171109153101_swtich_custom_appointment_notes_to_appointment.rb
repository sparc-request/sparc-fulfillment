class SwtichCustomAppointmentNotesToAppointment < ActiveRecord::Migration
  def change
    Note.where(notable_type: 'CustomAppointment').update_all(notable_type: 'Appointment')
  end
end
