require 'rails_helper'

feature 'User views Participant list', js: true do

  scenario 'and sees Participants' do
    given_i_am_viewing_the_participant_list
    then_i_should_see_participants
  end

  def given_i_am_viewing_the_participant_list
    @protocol = create_and_assign_protocol_to_me

    visit protocol_path(@protocol.id)
    wait_for_ajax

    click_link 'Participant List'
    wait_for_ajax
  end

  def then_i_should_see_participants
    participant_first_names = @protocol.participants.map(&:first_name)

    participant_first_names.each do |first_name|
      expect(page).to have_css('table.participants tbody td.first_name', text: first_name)
    end
  end
end
