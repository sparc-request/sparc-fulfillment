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

  scenario 'and sees a the Protocols table even when :irb_expiration_date is NULL' do
    create(:protocol_imported_from_sparc, irb_expiration_date: nil)
    visit root_path

    expect(page).to have_css('table.protocols td.irb_expiration_date', text: '')
  end

  scenario 'and sees a the Protocols table even when :irb_approval_date is NULL' do
    create(:protocol_imported_from_sparc, irb_approval_date: nil)
    visit root_path

    expect(page).to have_css('table.protocols td.irb_approval_date', text: '')
  end
end

