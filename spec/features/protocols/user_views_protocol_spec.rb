require 'rails_helper'

feature 'User views protocol', js: true do

  scenario 'Current IRB Expiration Date is correctly formatted' do
    create_protocols
    visit root_path
    page.find('table.protocols tbody tr:first-child').click
    expect(page).to have_css('.irb_expiration_date', text: /\d\d\/\d\d\/\d\d/)
  end
end
