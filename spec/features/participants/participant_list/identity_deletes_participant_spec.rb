require 'rails_helper'

feature 'User deletes Participant', js: true do

  scenario 'and sees the Participant is removed from the list' do
    given_i_am_viewing_the_participant_list
    when_i_delete_a_participant
    then_i_should_not_see_the_participant
  end

  def given_i_am_viewing_the_participant_list
    protocol = create_and_assign_protocol_to_me

    visit protocol_path(protocol.id)
    wait_for_ajax

    click_link 'Participant List'
    wait_for_ajax
  end

  def when_i_delete_a_participant
    accept_confirm do
      page.find('table.participants tbody tr:first-child td.delete a').click
    end

    refresh_bootstrap_table 'table.participants'
  end

  def then_i_should_not_see_the_participant
    expect(page).to have_css('#flashes_container', text: 'Participant Removed')
    expect(page).to have_css('table.participants tbody tr', count: 2)
  end
end
