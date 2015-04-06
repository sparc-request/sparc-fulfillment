require 'rails_helper'

feature 'User views Participant Tracker', js: true do

  before :each do
    protocol = create(:protocol_imported_from_sparc)

    visit protocol_path(protocol.sparc_id)
    click_link 'Participant Tracker'
  end

  scenario 'and sees Participants' do
    participant_first_names = Participant.all.map(&:first_name)

    participant_first_names.each do |first_name|
      expect(page).to have_css('table.participants tbody td.first_name', first_name)
    end
  end

  scenario 'and searches for an existing Participant' do
    participant = Participant.first

    search_bootstrap_table participant.first_name

    expect(page).to have_css('table.participants tbody tr:first-child td.first_name', text: participant.first_name)
  end

  scenario 'and updates the participant recruitment source' do
    participant = Participant.first
    find("#recruitment_source_#{participant.id}").select "Other"
    expect(page).to have_css ".alert-success"
  end
end
