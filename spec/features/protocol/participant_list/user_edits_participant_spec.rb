require 'rails_helper'

feature 'User edits Participant', js: true do

  scenario 'and sees the updated Participant' do
    protocol = create(:protocol_imported_from_sparc)

    visit protocol_path(protocol.sparc_id)
    click_link 'Participant List'
    page.find('table.participants tbody tr:first-child td.edit a').click
    fill_in 'First Name', with: 'Starlord'
    find("input[value='Save Participant']").click
    refresh_bootstrap_table 'table.participants'

    expect(page).to have_css('#flashes_container', text: 'Participant Saved')
    expect(page).to have_css('table.participants tbody tr td.first_name', text: 'Starlord')
  end
end
