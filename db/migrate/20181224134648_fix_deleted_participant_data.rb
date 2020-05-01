# Copyright © 2011-2020 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

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
