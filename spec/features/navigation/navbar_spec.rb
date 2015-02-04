require 'rails_helper'

feature 'Navigation', js: true do

  scenario 'User clicks on Home button' do
    create_protocols
    visit root_path

    page.find('table.protocols tbody tr:first-child').click
    click_button 'Home'

    expect(page.body).to have_css('table.protocols')
  end

  scenario 'User returns to protocol page from Participant Tracker page' do
    create_protocols
    visit root_path

    page.find('table.protocols tbody tr:first-child').click
    click_link 'Participant Tracker'
    page.find('table.participants tbody tr:first-child td a.calendar').click
    click_browser_back_button

    expect(page.body).to have_css('.tab-pane.active#participant_tracker')
  end
end
