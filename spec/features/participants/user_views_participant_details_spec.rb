require 'rails_helper'

feature 'User views Participant details', js: true do

  scenario 'and sees the Participants attributes' do
    given_i_am_viewing_the_participant_list
    when_i_click_the_participant_details_icon
    then_i_should_see_the_participant_details
  end

  def given_i_am_viewing_the_participant_list
    protocol    = create_and_assign_protocol_to_me

    visit protocol_path(protocol.id)
    click_link 'Participant List'
  end

  def when_i_click_the_participant_details_icon
    page.find('table.participants tbody tr:first-child td.details a').click
  end

  def then_i_should_see_the_participant_details
    expect(page).to have_css('.modal-title', text: 'Participant Details')
  end
end
