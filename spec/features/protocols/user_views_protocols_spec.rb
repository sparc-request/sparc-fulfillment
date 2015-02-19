require 'rails_helper'

feature 'User views protocols', js: true do

  scenario 'and sees Coordinators' do
    create_protocols
    visit root_path
    page.find('table.protocols tbody tr:first-child td.coordinators button').click

    expect(page).to have_css('table.protocols tr:first-child td.coordinators ul.dropdown-menu')
  end

  scenario 'and sees changes made by other Users in realtime' do
    protocols = create_protocols
    visit root_path

    protocols.first.update_attribute :short_title, 'Test 123'
    refresh_bootstrap_table('table.protocols')

    expect(page).to have_css('table.protocols td.short_title', text: 'Test 123')
  end
end
