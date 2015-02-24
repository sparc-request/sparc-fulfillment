require 'rails_helper'

feature 'User views Participant list', js: true do

  before do
    protocol = create(:protocol_imported_from_sparc)

    visit protocol_path(protocol.sparc_id)
    click_link 'Participant List'
  end

  scenario 'and sees Participants' do
    expect(page).to have_css('table.participants tbody td.last_name')
  end

  scenario 'and searches for an existing Participant' do
    participant = Participant.first

    search_bootstrap_table participant.first_name

    expect(page).to have_css('table.participants tbody tr:first-child td.first_name', text: participant.first_name)
  end

  scenario 'and searches for an non-existing Participant' do
    search_bootstrap_table 'Superman'

    expect(page).to have_css('table.participants tbody', text: 'No matching records found')
  end
end
