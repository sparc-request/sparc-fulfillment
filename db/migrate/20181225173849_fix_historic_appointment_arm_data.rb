class FixHistoricAppointmentArmData < ActiveRecord::Migration[5.2]
  def change
    CSV.open(Rails.root.join("tmp/fixed_appointment_arm_ids.csv"), "wb") do |csv|
      csv << ["Protocol/SSR ID", "Appointment ID", "Participant Name", "Appointment Name", "Incorrect Arm ID", "Correct (new) Arm ID"]
      bar = ProgressBar.new(Appointment.count)
      Appointment.find_each do |appointment|
        participant = Participant.where(id: appointment.participant_id).first
        if participant
          if (appointment.arm_id != participant.arm_id)
            old_arm_id = appointment.arm_id
            appointment.update_attribute(:arm_id, participant.arm_id)
            csv << [participant.protocol.srid, appointment.id, participant.full_name, appointment.name, old_arm_id, appointment.arm_id]
          end
        else
          csv << ["Participant has been deleted", appointment.id, "N/A", appointment.name, "N/A", "N/A"]
        end
        bar.increment!
      end
    end
  end
end
