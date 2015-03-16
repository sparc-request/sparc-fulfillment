require 'rails_helper'

feature 'User deletes Participant', js: true do

  scenario 'and sees the Participant is remove from the list' do
    protocol = create(:protocol_imported_from_sparc)

    visit protocol_path(protocol.sparc_id)
    click_link 'Participant List'
    accept_confirm do
      page.find('table.participants tbody tr:first-child td.delete a').click
    end
    refresh_bootstrap_table 'table.participants'

    expect(page).to have_css('#flashes_container', text: 'Participant Removed')
    expect(page).to have_css('table.participants tbody tr', count: 2)
  end
end
