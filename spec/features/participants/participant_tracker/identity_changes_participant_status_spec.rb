require 'rails_helper'

feature 'User changes the status of a participant on the participant tracker', js: true do

  scenario 'and sees the updated status on the page' do
    given_i_am_viewing_the_participant_tracker
    when_i_update_the_participant_status
    then_i_should_see_the_updated_status
  end

  scenario 'and sees the status updated note' do
    given_i_am_viewing_the_participant_tracker
    when_i_update_the_participant_status
    then_i_should_see_an_associated_note
  end

  def given_i_am_viewing_the_participant_tracker
    @protocol    = create_and_assign_protocol_to_me
    @participant = @protocol.participants.first

    visit protocol_path @protocol.id
    wait_for_ajax

    click_link 'Participant Tracker'
    wait_for_ajax
  end

  def when_i_update_the_participant_status
    bootstrap_select "#participant_status_#{@participant.id}", "Screening"
    wait_for_ajax

    refresh_bootstrap_table 'table.participants'
    wait_for_ajax
  end

  def then_i_should_see_the_updated_status
    expect(bootstrap_selected?("participant_status_#{@participant.id}", "Screening")).to be
  end

  def then_i_should_see_an_associated_note
    expect(bootstrap_selected?("participant_status_#{@participant.id}", "Screening")).to be
    wait_for_ajax
    find("button.participant_notes[data-notable-id='#{@participant.id}']").click
    wait_for_ajax

    expect(page).to have_content('Status changed')
  end
end
