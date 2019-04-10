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
  desc "Merge duplicate Participants"
  task merge_duplicate_participants: :environment do

    def process_participant_to_be_retained(row, participant_id, participant_to_retain, csv)
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
      
      csv << ["Updated Participant", "", participant_to_retain.id, participant_to_retain.sparc_id, participant_to_retain.protocol_id, participant_to_retain.arm_id, participant_to_retain.first_name, participant_to_retain.last_name, participant_to_retain.mrn, participant_to_retain.status, participant_to_retain.date_of_birth, participant_to_retain.gender, participant_to_retain.ethnicity, participant_to_retain.race, participant_to_retain.address, participant_to_retain.phone, participant_to_retain.deleted_at, participant_to_retain.created_at, participant_to_retain.updated_at, participant_to_retain.total_cost, participant_to_retain.city, participant_to_retain.state, participant_to_retain.zipcode, participant_to_retain.recruitment_source, participant_to_retain.external_id, participant_to_retain.middle_initial]
      
      participant_to_retain.update_attributes(first_name: first_name, last_name: last_name, mrn: mrn, status: status, date_of_birth: dob, gender: gender, ethnicity: ethnicity, race: race, address: address, phone: phone, city: city, state: state, zipcode: zipcode, external_id: external_id)

      csv << ["Participant after update", "", participant_to_retain.id, participant_to_retain.sparc_id, participant_to_retain.protocol_id, participant_to_retain.arm_id, participant_to_retain.first_name, participant_to_retain.last_name, participant_to_retain.mrn, participant_to_retain.status, participant_to_retain.date_of_birth, participant_to_retain.gender, participant_to_retain.ethnicity, participant_to_retain.race, participant_to_retain.address, participant_to_retain.phone, participant_to_retain.deleted_at, participant_to_retain.created_at, participant_to_retain.updated_at, participant_to_retain.total_cost, participant_to_retain.city, participant_to_retain.state, participant_to_retain.zipcode, participant_to_retain.recruitment_source, participant_to_retain.external_id, participant_to_retain.middle_initial]
    end

    def process_participant_to_be_destroyed(participant_to_destroy, participant_to_retain, csv)

      csv << ["Updated Participant ID on ProtocolsParticipant", ProtocolsParticipant.where(participant_id: participant_to_destroy.id).map(&:id)]

      ProtocolsParticipant
        .where(participant_id: participant_to_destroy.id)
        .update_all(participant_id: participant_to_retain.id)

      csv << ["Deleted Participant", "", participant_to_destroy.id, participant_to_destroy.sparc_id, participant_to_destroy.protocol_id, participant_to_destroy.arm_id, participant_to_destroy.first_name, participant_to_destroy.last_name, participant_to_destroy.mrn, participant_to_destroy.status, participant_to_destroy.date_of_birth, participant_to_destroy.gender, participant_to_destroy.ethnicity, participant_to_destroy.race, participant_to_destroy.address, participant_to_destroy.phone, participant_to_destroy.deleted_at, participant_to_destroy.created_at, participant_to_destroy.updated_at, participant_to_destroy.total_cost, participant_to_destroy.city, participant_to_destroy.state, participant_to_destroy.zipcode, participant_to_destroy.recruitment_source, participant_to_destroy.external_id, participant_to_destroy.middle_initial]
      participant_to_destroy.destroy
      Participant.only_deleted.where(id: participant_to_destroy.id).delete_all
    end
    #### csv location tmp/patient_registry.csv
    #### Patient ID (Records to Merge), Patient MRN, Patient Name, Patient Middle Name, Patient Status, Patient DOB, Patient Gender, Patient Ethnicity, Patient Race, Patient Address, Patient Phone Number, Patient City, Patient State, Patient Zip Code, Patient External ID
    participant_ids_that_do_not_exist = []
    CSV.open("tmp/participant_changes.csv", "wb") do |csv|
       csv << ["Script Action", "ProtocolsParticipant ID(s)", "Participant ID", "Sparc ID", "Protocol ID", "Arm ID", "First Name", "Last Name", "MRN", "Status", "DOB", "Gender", "Ethnicity", "Race", "Address", "Phone", "Deleted At", "Created At", "Updated At", "Total Cost", "City", "State", "Zipcode", "Recruitment Source", "External ID", "Middle Initial"]
      CSV.foreach("tmp/patient_registry.csv", headers: true, :encoding => 'windows-1251:utf-8') do |row|
    
        csv << ["//////////////////"]

        if !row['Patient ID (Records to Merge)'].nil?
          participant_ids = row['Patient ID (Records to Merge)'].split(';').map{|id| id.strip}
          
          participant_ids.each_with_index do |participant_id, index|

            if index == 0 || @participant_to_retain.nil? ### Grab first Participant and update
              @participant_to_retain = Participant.find_by(id: participant_id)
              if @participant_to_retain.nil?
                ### permanently delete record
                if deleted_participant = Participant.with_deleted.find_by(id: participant_id)
                  csv << ["Deleted Participant", "", deleted_participant.id, deleted_participant.sparc_id, deleted_participant.protocol_id, deleted_participant.arm_id, deleted_participant.first_name, deleted_participant.last_name, deleted_participant.mrn, deleted_participant.status, deleted_participant.date_of_birth, deleted_participant.gender, deleted_participant.ethnicity, deleted_participant.race, deleted_participant.address, deleted_participant.phone, deleted_participant.deleted_at, deleted_participant.created_at, deleted_participant.updated_at, deleted_participant.total_cost, deleted_participant.city, deleted_participant.state, deleted_participant.zipcode, deleted_participant.recruitment_source, deleted_participant.external_id, deleted_participant.middle_initial]
                  deleted_participant.destroy
                  Participant.only_deleted.where(id: deleted_participant.id).delete_all
                else
                  participant_ids_that_do_not_exist << participant_id
                  csv << ["ID does not exisit", participant_id]
                end
                next
              end
              process_participant_to_be_retained(row, participant_id, @participant_to_retain, csv)
            else
              participant_to_destroy = Participant.find_by(id: participant_id)
              if participant_to_destroy.nil?
                ### permanently delete record
                if deleted_participant = Participant.with_deleted.find_by(id: participant_id)
                  csv << ["Deleted Participant", "", deleted_participant.id, deleted_participant.sparc_id, deleted_participant.protocol_id, deleted_participant.arm_id, deleted_participant.first_name, deleted_participant.last_name, deleted_participant.mrn, deleted_participant.status, deleted_participant.date_of_birth, deleted_participant.gender, deleted_participant.ethnicity, deleted_participant.race, deleted_participant.address, deleted_participant.phone, deleted_participant.deleted_at, deleted_participant.created_at, deleted_participant.updated_at, deleted_participant.total_cost, deleted_participant.city, deleted_participant.state, deleted_participant.zipcode, deleted_participant.recruitment_source, deleted_participant.external_id, deleted_participant.middle_initial]
                  deleted_participant.destroy
                  Participant.only_deleted.where(id: deleted_participant.id).delete_all
                else
                  participant_ids_that_do_not_exist << participant_id
                  csv << ["ID does not exisit", participant_id]
                end
                next
              end
              process_participant_to_be_destroyed(participant_to_destroy, @participant_to_retain, csv)
            end
          end
        end
      end
    end
    puts "Participant IDs that do not exist: #{participant_ids_that_do_not_exist}"
  end
end
