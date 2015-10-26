require 'rails_helper'

feature 'User views Participant Tracker', js: true do

  scenario 'and sees Participants' do
    given_i_am_viewing_the_participant_tracker
    then_i_should_see_participants
  end

  scenario 'and searches for an existing Participant' do
    given_i_am_viewing_the_participant_tracker
    when_i_search_for_an_existing_participant
    then_i_should_see_the_participant_i_searched_for
  end

  scenario 'and searches for an non-existing Participant' do
    given_i_am_viewing_the_participant_tracker
    when_i_search_for_a_nonexistent_participant
    then_i_should_not_see_the_participant_i_searched_for
  end

  def given_i_am_viewing_the_participant_tracker
    protocol = create_and_assign_protocol_to_me

    visit protocol_path(protocol.id)
    click_link 'Participant Tracker'
  end

  def when_i_search_for_an_existing_participant
    @participant = Participant.first

    search_bootstrap_table @participant.first_name
  end

  def when_i_search_for_a_nonexistent_participant
    search_bootstrap_table 'Superman'
  end

  def then_i_should_see_participants
    participant_first_names = Participant.all.map(&:first_name)

    participant_first_names.each do |first_name|
      expect(page).to have_css('table.participants tbody td.first_name', first_name)
    end
  end

  def then_i_should_see_the_participant_i_searched_for
    expect(page).to have_css('table.participants tbody tr:first-child td.first_name', text: @participant.first_name)
  end

  def then_i_should_not_see_the_participant_i_searched_for
    expect(page).to have_css('table.participants tbody', text: 'No matching records found')
  end
end
