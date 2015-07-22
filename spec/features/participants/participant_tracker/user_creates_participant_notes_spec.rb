require 'rails_helper'

feature 'User views the participant tracker page', js: true do

  before :each do
    given_i_am_viewing_the_participant_tracker
  end

  scenario 'and then trys to create a particpant note' do
    when_i_click_on_the_notes_button
    i_should_see_the_notes_modal
    and_if_i_add_a_comment_and_save
    when_i_click_on_the_notes_button
    i_should_see_the_note_in_the_index
  end

  scenario 'and changes the participant arm which should create a note' do
    if_i_change_the_particpants_arm
    when_i_click_on_the_notes_button
    i_should_see_the_arm_change_note_in_the_index
  end

  def given_i_am_viewing_the_participant_tracker
    @protocol = create_and_assign_protocol_to_me
    @participant = @protocol.participants.first

    visit protocol_path @protocol
    click_link 'Participant Tracker'
  end

  def when_i_click_on_the_notes_button
    first('.participant_notes').click
    wait_for_ajax
  end

  def i_should_see_the_notes_modal
    expect(page).to have_content('Participant Notes')
  end

  def and_if_i_add_a_comment_and_save
    find('.new').click
    wait_for_ajax
    fill_in 'Comment', with: "Action Jackson"
    click_button 'Save'
    wait_for_ajax
  end

  def i_should_see_the_note_in_the_index
    expect(page).to have_content('Action Jackson')
  end

  def if_i_change_the_particpants_arm
    second_arm  = @protocol.arms.second

    first('.change-arm').click
    select second_arm.name, from: 'Current Arm'
    click_button 'Save'
    wait_for_ajax
  end

  def i_should_see_the_arm_change_note_in_the_index
    first_arm_name = @participant.arm.name
    second_arm_name = @protocol.arms.second.name

    expect(page).to have_content("Arm changed from #{first_arm_name} to #{second_arm_name}")
  end
end