require 'rails_helper'

feature 'User creates Participant', js: true do

  scenario 'and sees the new Participants in the list' do
    protocol = create(:protocol_imported_from_sparc)

    visit protocol_path(protocol.sparc_id)
    click_link 'Participant List'
    click_link 'Create New Participant'
    user_fills_in_new_participant_form
    find("input[value='Save Participant']").click
    refresh_bootstrap_table 'table.participants'
    expect(page).to have_css('#flashes_container', text: 'Participant Created')
    expect(page).to have_css('table.participants tbody tr', count: 4)
  end

  def user_fills_in_new_participant_form
    participant = build(:participant_with_protocol)

    fill_in 'First Name', with: participant.first_name
    fill_in 'Last Name', with: participant.last_name
    fill_in 'MRN', with: participant.mrn
    select participant.status, from: 'Status'
    page.execute_script %Q{ $("#participant_date_of_birth").siblings(".input-group-addon").trigger("click") }
    page.execute_script %Q{ $("td.year:contains('0')").trigger("click") }
    page.execute_script %Q{ $("td.month:contains('Mar')").trigger("click") }
    page.execute_script %Q{ $("td.day:contains('15')").trigger("click") }
    select participant.gender, from: 'Gender'
    select participant.ethnicity, from: 'Ethnicity'
    select participant.race, from: 'Race'
    fill_in 'Address', with: participant.address
    fill_in 'Phone', with: participant.phone
  end
end
