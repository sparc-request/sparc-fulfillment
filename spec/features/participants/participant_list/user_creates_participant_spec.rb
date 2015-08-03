require 'rails_helper'

feature 'User creates Participant', js: true do

  scenario 'and sees the new Participants in the list' do
    given_i_am_viewing_the_participant_list
    when_i_create_a_new_participant
    then_i_should_see_the_new_participant_in_the_list
  end

  def given_i_am_viewing_the_participant_list
    protocol = create_and_assign_protocol_to_me

    visit protocol_path(protocol.id)
    click_link 'Participant List'
  end

  def when_i_create_a_new_participant
    click_link 'Create New Participant'

    participant = build(:participant_with_protocol)

    fill_in 'First Name', with: participant.first_name
    fill_in 'Last Name', with: participant.last_name
    fill_in 'MRN', with: participant.mrn
    fill_in 'City', with: participant.city
    bootstrap_select '#participant_state', participant.state
    fill_in 'Zip Code', with: participant.zipcode
    bootstrap_select '#participant_status', participant.status
    page.execute_script %Q{ $("#participant_date_of_birth").siblings(".input-group-addon").trigger("click") }
    page.execute_script %Q{ $("td.year:contains('0')").trigger("click") }
    page.execute_script %Q{ $("td.month:contains('Mar')").trigger("click") }
    page.execute_script %Q{ $("td.day:contains('15')").trigger("click") }
    bootstrap_select '#participant_gender', participant.gender
    bootstrap_select '#participant_ethnicity', participant.ethnicity
    bootstrap_select '#participant_race', participant.race
    fill_in 'Address', with: participant.address
    fill_in 'Phone', with: participant.phone

    find("input[value='Save Participant']").click

    refresh_bootstrap_table 'table.participants'
  end

  def then_i_should_see_the_new_participant_in_the_list
    expect(page).to have_css('#flashes_container', text: 'Participant Created')
    expect(page).to have_css('table.participants tbody tr', count: 4)
  end
end
