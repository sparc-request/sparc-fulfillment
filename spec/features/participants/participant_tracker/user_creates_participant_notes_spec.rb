require 'rails_helper'

feature 'User views the participant tracker page', js: true do

  context 'and then tries to create a particpant note' do
    scenario 'and sees the notes modal' do
      given_i_am_viewing_the_participant_tracker
      when_i_click_on_the_notes_button
      then_i_should_see_the_notes_modal
    end

    scenario 'and create a participant note' do
      given_i_am_viewing_the_participant_tracker
      when_i_click_on_the_notes_button
      when_i_add_a_comment_and_save
      when_i_click_on_the_notes_button
      then_i_should_see_the_note_in_the_index
    end
  end

  scenario 'and changes the participant arm which should create a note' do
    given_i_am_viewing_the_participant_tracker
    when_i_change_the_particpants_arm
    when_i_click_on_the_notes_button
    then_i_should_see_the_arm_change_note_in_the_index
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

  def when_i_add_a_comment_and_save
    find('.new').click
    wait_for_ajax
    fill_in 'Comment', with: "Action Jackson"
    click_button 'Save'
    wait_for_ajax
  end

  def when_i_change_the_particpants_arm
    second_arm  = @protocol.arms.second

    first('.change-arm').click
    select second_arm.name, from: 'Current Arm'
    click_button 'Save'
    wait_for_ajax
  end

  def then_i_should_see_the_notes_modal
    expect(page).to have_content('Participant Notes')
  end

  def then_i_should_see_the_note_in_the_index
    expect(page).to have_content('Action Jackson')
  end

  def then_i_should_see_the_arm_change_note_in_the_index
    first_arm_name = @participant.arm.name
    second_arm_name = @protocol.arms.second.name

    expect(page).to have_content("Arm changed from #{first_arm_name} to #{second_arm_name}")
  end
end