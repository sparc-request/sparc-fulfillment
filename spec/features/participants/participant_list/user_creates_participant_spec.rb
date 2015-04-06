require 'rails_helper'

feature 'User creates Participant', js: true do

  scenario 'and sees the new Participants in the list' do
    protocol = create(:protocol_imported_from_sparc)

    visit protocol_path(protocol.sparc_id)
    click_link 'Participant List'
    click_link 'Create New Participant'
    user_fills_in_new_participant_form
    find("input[value='Save Participant']").click
    refresh_bootstrap_table 'table.participants'

    expect(page).to have_css('#flashes_container', text: 'Participant Created')
    expect(page).to have_css('table.participants tbody tr', count: 4)
  end
end
