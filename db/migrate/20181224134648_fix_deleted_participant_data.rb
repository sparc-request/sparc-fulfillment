class Appointment < ApplicationRecord
  belongs_to :participant
  has_many :procedures
end

class FixDeletedParticipantData < ActiveRecord::Migration[5.2]
  def change
    CSV.open(Rails.root.join("tmp/fixed_missing_participants.csv"), "wb") do |csv|
      csv << ["Appointment ID", "Appointment Name", "Participant ID", "Participant Name", "Action Taken"]
      ##Appointments where participant is missing
      appointments = Appointment.includes(:participant).where(participants: {id: nil})
      bar = ProgressBar.new(appointments.count)

      appointments.each do |appointment|
        deleted_participant = Participant.with_deleted.where(id: appointment.participant_id).first
        if deleted_participant
          ##Participant was soft deleted
          if appointment.procedures.where.not(status: "unstarted").any?
            ##Appointment has data, participant should be un-deleted
            csv << [appointment.id, appointment.name, appointment.participant_id, deleted_participant.full_name, "Appointment had data, so participant was un-deleted"]
            deleted_participant.restore
          else
            ##Appointment does not have data, can be deleted
            csv << [appointment.id, appointment.name, appointment.participant_id, deleted_participant.full_name, "Appointment had no data, appointment deleted"]
            appointment.destroy
          end
        else
          ##Participant was really deleted, not soft deleted
          if appointment.procedures.where.not(status: "unstarted").any?
            ##Appointment has data
            csv << [appointment.id, appointment.name, appointment.participant_id, "N/A", "Participant was truly deleted, and appointment has procedure data, no action taken (requires more investigation)"]
          else
            ##Appointment does NOT have data, and can be deleted
            csv << [appointment.id, appointment.name, appointment.participant_id, "N/A", "Participant was truly deleted, but appointment had no data, appointment deleted"]
            appointment.destroy
          end
        end
        bar.increment!
      end
    end
  end
end
