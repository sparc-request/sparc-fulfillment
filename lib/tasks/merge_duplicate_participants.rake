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

namespace :data do
  desc "Merge duplicate Participants"
  task merge_duplicate_participants: :environment do

    def process_participant_to_be_retained(row, participant_id, participant_to_retain)
      first_name = row['Patient Name'].split(' ').first
      last_name = row['Patient Name'].split(' ').last
      mrn = row['Patient MRN']
      status = row['Patient Status']
      dob = row['Patient DOB']
      gender = row['Patient Gender']
      ethnicity = row['Patient Ethnicity']
      race = row['Patient Race']
      address = row['Patient Address']
      phone = row['Patient Phone Number']
      city = row['Patient City']
      state = row['Patient State']
      zipcode = row['Patient Zip Code']
      external_id = row['Patient External ID']

      participant_to_retain.update_attributes(first_name: first_name, last_name: last_name, mrn: mrn, status: status, date_of_birth: dob, gender: gender, ethnicity: ethnicity, race: race, address: address, phone: phone, city: city, state: state, zipcode: zipcode, external_id: external_id)
    end

    def process_participant_to_be_destroyed(participant_to_destroy, participant_to_retain)
      ProtocolsParticipant
        .where(participant_id: participant_to_destroy.id)
        .update_all(participant_id: participant_to_retain.id)
      ### Find Participant an
      participant_to_destroy.destroy
      Participant.only_deleted.where(id: participant_to_destroy.id).delete_all
    end
    #### csv location tmp/patient_registry.csv
    #### Patient ID (Records to Merge), Patient MRN, Patient Name, Patient Middle Name, Patient Status, Patient DOB, Patient Gender, Patient Ethnicity, Patient Race, Patient Address, Patient Phone Number, Patient City, Patient State, Patient Zip Code, Patient External ID
    participant_ids_that_do_not_exist = []
    CSV.foreach("tmp/patient_registry.csv", headers: true, :encoding => 'windows-1251:utf-8') do |row|
      if !row['Patient ID (Records to Merge)'].nil?
        participant_ids = row['Patient ID (Records to Merge)'].split(';').map{|id| id.strip}
        
        participant_ids.each_with_index do |participant_id, index|
          if index == 0 || @participant_to_retain.nil? ### Grab first Participant and update
            @participant_to_retain = Participant.find_by(id: participant_id)
            if @participant_to_retain.nil?
              ### permanently delete record
              if deleted_participant = Participant.with_deleted.find_by(id: participant_id)
                deleted_participant.destroy
                Participant.only_deleted.where(id: deleted_participant.id).delete_all
              else
                participant_ids_that_do_not_exist << participant_id
              end
              next
            end
            process_participant_to_be_retained(row, participant_id, @participant_to_retain)
          else
            participant_to_destroy = Participant.find_by(id: participant_id)
            if participant_to_destroy.nil?
              ### permanently delete record
              if deleted_participant = Participant.with_deleted.find_by(id: participant_id)
                deleted_participant.destroy
                Participant.only_deleted.where(id: deleted_participant.id).delete_all
              else
                participant_ids_that_do_not_exist << participant_id
              end
              next
            end
            process_participant_to_be_destroyed(participant_to_destroy, @participant_to_retain)
          end
        end
      end
    end
    puts "Participant IDs that do not exist: #{participant_ids_that_do_not_exist}"
  end
end
