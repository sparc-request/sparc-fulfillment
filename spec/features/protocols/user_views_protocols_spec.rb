require 'rails_helper'

feature 'User views protocols', js: true do

  scenario 'and sees Coordinators' do
    create_protocols
    visit root_path
    page.find('table.protocols tbody tr:first-child td.coordinators button').click

    expect(page).to have_css('table.protocols tr:first-child td.coordinators ul.dropdown-menu')
  end
end
