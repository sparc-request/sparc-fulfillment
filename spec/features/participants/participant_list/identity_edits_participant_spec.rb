require 'rails_helper'

feature 'User edits Participant', js: true do

  scenario 'and sees the updated Participant' do
    given_i_am_viewing_the_participant_list
    when_i_update_a_participants_details
    then_i_should_see_the_updated_details
  end

  def given_i_am_viewing_the_participant_list
    protocol = create_and_assign_protocol_to_me

    visit protocol_path(protocol.id)
    wait_for_ajax

    click_link 'Participant List'
    wait_for_ajax
  end

  def when_i_update_a_participants_details
    page.find('table.participants tbody tr:first-child td.edit a').click

    fill_in 'First Name', with: 'Starlord'
    page.execute_script %Q{ $('#dob_time_picker').trigger("focus") }
    page.execute_script %Q{ $("td.day:contains('15')").trigger("click") }
    
    find("input[value='Save Participant']").click
    
    refresh_bootstrap_table 'table.participants'
  end

  def then_i_should_see_the_updated_details
    expect(page).to have_css('#flashes_container', text: 'Participant Updated')
    expect(page).to have_css('table.participants tbody tr td.first_name', text: 'Starlord')
  end
end
