require 'rails_helper'

feature 'User views Participant Tracker', js: true do

  scenario 'and sees Participants' do
    given_i_am_viewing_the_participant_tracker
    then_i_should_see_participants
  end

  def given_i_am_viewing_the_participant_tracker
    protocol = create_and_assign_protocol_to_me

    visit protocol_path(protocol.id)
    wait_for_ajax

    click_link 'Participant Tracker'
    wait_for_ajax
  end

  def then_i_should_see_participants
    participant_first_names = Participant.all.map(&:first_name)

    participant_first_names.each do |first_name|
      expect(page).to have_css('table.participants tbody td.first_name', first_name)
    end
  end
end
