require 'rails_helper'

feature 'User views Participant details', js: true do

  scenario 'and sees the Participants attributes' do
    protocol    = create_and_assign_protocol_to_me

    visit protocol_path(protocol.id)
    click_link 'Participant List'
    page.find('table.participants tbody tr:first-child td.details a').click

    expect(page).to have_css('.modal-title', text: 'Participant Details')
  end
end
