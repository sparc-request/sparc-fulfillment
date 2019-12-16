# Copyright © 2011-2018 MUSC Foundation for Research Development~
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

### Patient DOB column needs to be in this format:  "Month/Date/Year".  Example:  "2/27/1953".
### Last time we had errors because a column name was not named the correct way:  'Patient External ID'
namespace :data do
  desc "Report For Appointment Data Related To Duplicate Participants With Same Protocol ID"
  task report_for_appointment_data: :environment do

    def report_appointment_data(participants_with_same_protocol_id, csv)
      csv << ["//////////////////"]
      csv << ["Able to Merge?", "Participant ID", "Participant Name", "Arm Name", "ProtocolsParticipant ID(s)", "Appointment ID", "Sparc ID", "Visit Group ID", "Visit Group Position", "Position", "Name", "Start Date", "Completed Date", "Deleted At", "Created At", "Updated At", "Contents", "Type", "Arm ID"]
      appointment_size = participants_with_same_protocol_id.map(&:appointments).map(&:size)
      if !(appointment_size.include? 0)
        participants_with_same_protocol_id.each do |participant|
          participant.protocols_participants.each do |protocols_participant|
            protocols_participant.appointments.each do |appointment|
              csv << ["No", participant.id, participant.full_name, Arm.find_by_id(appointment.arm_id).try(:name), protocols_participant.id, appointment.id, appointment.sparc_id, appointment.visit_group_id, appointment.visit_group_position, appointment.position, appointment.name, appointment.start_date, appointment.completed_date, appointment.deleted_at, appointment.created_at, appointment.updated_at, appointment.contents, appointment.type, appointment.arm_id]
            end
          end
        end
      else
        participants_with_same_protocol_id.each do |participant|
          csv << [participant.id, participants_with_same_protocol_id.first.protocols_participants.ids]
          participant.protocols_participants.each do |protocols_participant|
            protocols_participant.appointments.each do |appointment|
              csv << ["Yes", participant.id, participant.full_name, Arm.find_by_id(appointment.arm_id).try(:name), protocols_participant.id, appointment.id, appointment.sparc_id, appointment.visit_group_id, appointment.visit_group_position, appointment.position, appointment.name, appointment.start_date, appointment.completed_date, appointment.deleted_at, appointment.created_at, appointment.updated_at, appointment.contents, appointment.type, appointment.arm_id]
            end
          end
        end
      end
    end

    @participant_ids_that_do_not_exist = []
    CSV.open("tmp/appointment_data.csv", "wb") do |csv|
      csv << ["Duplicate Participants With Same Protocol ID"]
      CSV.foreach("tmp/patient_registry_2.csv", headers: true, :encoding => 'windows-1251:utf-8') do |row|
        if !row['Patient ID (Records to Merge)'].nil?
          participant_ids = row['Patient ID (Records to Merge)'].split(';').map{|id| id.strip}

          protocols_with_duplicate_participants = []
          protocols_with_duplicate_participants << participant_ids.map{|participant_id| Participant.find_by(id: participant_id).try(:protocol_id)}.group_by{ |e| e }.select { |k, v| v.size > 1 }.map(&:first).first

          participants_with_same_protocol_id = Participant.where(id: participant_ids).where(protocol_id: protocols_with_duplicate_participants.first)

          if participants_with_same_protocol_id.present?
            report_appointment_data(participants_with_same_protocol_id, csv)
          end
        end
      end
    end
  end
end
