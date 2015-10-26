require 'rails_helper'

feature 'Identity edits arms on protocol study schedule', js: true do

  context 'User adds an arm' do
    context 'and fills the form out correctly' do
      scenario 'and sees the new arm is created' do
        given_i_am_viewing_a_protocol_with_one_arm
        when_i_click_the_add_arm_button
        when_i_fill_in_the_form
        when_i_click_the_add_submit_button
        then_i_should_see_the_new_arm
      end

      scenario 'and sees a flash message' do
        given_i_am_viewing_a_protocol_with_one_arm
        when_i_click_the_add_arm_button
        when_i_fill_in_the_form
        when_i_click_the_add_submit_button
        then_i_should_see_a_flash_message_of_type 'add'
      end
    end

    context 'and fills the form out incorrectly' do
      scenario 'and sees errors' do
        given_i_am_viewing_a_protocol_with_one_arm
        when_i_click_the_add_arm_button
        when_i_click_the_add_submit_button
        then_i_should_see_errors_of_type 'add'
      end
    end
  end

  context 'User edits an arm' do
    context 'and fills the form out correctly' do
      scenario 'and sees the updated arm' do
        given_i_am_viewing_a_protocol_with_one_arm
        when_i_click_the_edit_arm_button
        when_i_set_the_name_to 'other arm name'
        when_i_set_the_subject_count_to 1234
        when_i_click_the_save_submit_button
        then_i_should_see_the_updated_arm
      end

      scenario 'and sees a flash message' do
        given_i_am_viewing_a_protocol_with_one_arm
        when_i_click_the_edit_arm_button
        when_i_set_the_name_to 'other arm name'
        when_i_set_the_subject_count_to 1234
        when_i_click_the_save_submit_button
        then_i_should_see_a_flash_message_of_type 'edit'
      end
    end

    context 'and fills the form out incorrectly' do
      scenario 'and sees errors' do
        given_i_am_viewing_a_protocol_with_one_arm
        when_i_click_the_edit_arm_button
        when_i_set_the_name_to ''
        when_i_set_the_subject_count_to nil
        when_i_click_the_save_submit_button
        then_i_should_see_errors_of_type 'edit'
      end
    end
  end

  context 'User deletes an arm' do
    scenario 'and does not see the arm' do
      given_i_am_viewing_a_protocol_with_multiple_arms
      when_i_click_the_remove_arm_button
      when_i_click_the_remove_submit_button
      then_i_should_not_see_the_arm
    end

    scenario 'and sees a flash message' do
      given_i_am_viewing_a_protocol_with_multiple_arms
      when_i_click_the_remove_arm_button
      when_i_click_the_remove_submit_button
      then_i_should_see_a_flash_message_of_type 'remove'
    end
  end

  context 'User tries to delete an arm with fulfillments' do
    scenario 'and sees an error' do
      given_i_am_viewing_a_protocol_with_multiple_arms
      given_there_is_an_arm_with_completed_procedures
      when_i_click_the_remove_arm_button
      when_i_select_the_arm_with_completed_procedures
      when_i_click_the_remove_submit_button
      then_i_should_see_errors_of_type 'has_fulfillments'
    end

    scenario 'and sees the arm' do
      given_i_am_viewing_a_protocol_with_multiple_arms
      given_there_is_an_arm_with_completed_procedures
      when_i_click_the_remove_arm_button
      when_i_select_the_arm_with_completed_procedures
      when_i_click_the_remove_submit_button
      when_i_click_the_close_submit_button
      then_i_should_still_see_the_arm
    end
  end

  context 'User tries to delete the last arm' do 
    scenario 'and sees the arm' do
      given_i_am_viewing_a_protocol_with_one_arm
      when_i_click_the_remove_arm_button
      when_i_click_the_remove_submit_button
      when_i_click_the_close_submit_button
      then_i_should_still_see_the_arm
    end
  end


  def given_i_am_viewing_a_protocol_with_one_arm
    @protocol = create_and_assign_protocol_to_me
    @protocol.arms.each do |arm|
      if @protocol.arms.count != 1
        arm.delete
      end
    end
    visit protocol_path @protocol
  end

  def given_i_am_viewing_a_protocol_with_multiple_arms
    @protocol = create_and_assign_protocol_to_me
    arm       = create(:arm, protocol: @protocol)
    visit protocol_path @protocol
  end


  def given_there_is_an_arm_with_completed_procedures
    participant  = create(:participant_with_appointments, protocol: @protocol, arm: @protocol.arms.first)
    procedure    = create(:procedure_complete, appointment: participant.appointments.first, arm: @protocol.arms.first, status: "complete", completed_date: "10-09-2010")
    visit protocol_path @protocol
  end

  def when_i_click_the_add_arm_button
    find("#add_arm_button").click
  end

  def when_i_click_the_remove_arm_button
    find("#remove_arm_button").click
    wait_for_ajax
  end

  def when_i_click_the_edit_arm_button
    find("#edit_arm_button").click
  end

  def when_i_fill_in_the_form
    fill_in 'Arm Name', with: 'arm name'
    fill_in 'Subject Count', with: 1
    fill_in 'Visit Count', with: 3
  end

  def when_i_set_the_name_to name
    fill_in 'Arm Name', with: name
  end
  
  def when_i_set_the_subject_count_to count
    fill_in 'Subject Count', with: count
  end

  def when_i_click_the_add_submit_button
    click_button 'Add'
  end

  def when_i_click_the_remove_submit_button
    click_button 'Remove'
  end

  def when_i_click_the_save_submit_button
    click_button "Save"
  end

  def when_i_click_the_close_submit_button
    click_button "Close"
  end

  def when_i_select_the_arm_with_completed_procedures
    bootstrap_select "#arm_form_select", @protocol.arms.first.name
  end

  def when_i_accept_the_confirmation_alert
    page.accept_alert do
      click_button('OK')
    end
  end

  def then_i_should_see_the_new_arm
    expect(find(".study_schedule_container")).to have_content "arm name"
  end

  def then_i_should_see_the_updated_arm
    expect(find(".study_schedule_container")).to have_content "other arm name"
  end

  def then_i_should_not_see_the_arm
    expect(find(".study_schedule_container")).not_to have_content @protocol.arms.first.name #The first arm is gone
  end

  def then_i_should_still_see_the_arm
    expect(find(".study_schedule_container")).to have_content @protocol.arms.last.name #The last arm (with procedures) is gone
  end

  def then_i_should_see_errors_of_type action_type
    case action_type
      when 'add'
        expect(page).to have_content("Name can't be blank")
        expect(page).to have_content("Subject count is not a number")
        expect(page).to have_content("Visit count is not a number")
      when 'edit'
        expect(page).to have_content("Name can't be blank")
        expect(page).to have_content("Subject count is not a number")
      when 'has_fulfillments'
        expect(page).to have_content("has completed procedures and cannot be deleted")
    end
  end

  def then_i_should_see_a_flash_message_of_type action_type
    case action_type
      when 'add'
        expect(page).to have_content("Arm Created")
      when 'edit'
        expect(page).to have_content("Arm Updated")
      when 'remove'
        expect(page).to have_content("Arm Destroyed")
    end
  end
end
