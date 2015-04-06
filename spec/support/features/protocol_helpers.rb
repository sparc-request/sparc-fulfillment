module Features

  module ProtocolHelpers

    def create_protocols(count=1)
      create_list(:protocol_imported_from_sparc, count)
    end

    def user_fills_in_new_participant_form
      participant = build(:participant)

      fill_in 'First Name', with: participant.first_name
      fill_in 'Last Name', with: participant.last_name
      fill_in 'MRN', with: participant.mrn
      select participant.status, from: 'Participant Status'
      page.execute_script %Q{ $('#dob_time_picker').trigger("focus") }
      page.execute_script %Q{ $("td.day:contains('15')").trigger("click") }
      select participant.gender, from: 'Gender'
      select participant.ethnicity, from: 'Ethnicity'
      select participant.race, from: 'Race'
      fill_in 'Address', with: participant.address
      fill_in 'Phone', with: participant.phone
    end
  end
end
