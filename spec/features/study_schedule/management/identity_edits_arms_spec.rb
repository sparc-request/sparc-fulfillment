require 'rails_helper'

feature 'Identity edits arms on protocol study schedule', js: true do

  scenario 'identity adds a new arm to the protocol' do
    given_a_protocol_with_one_arm
    when_i_add_an_arm
    and_i_fill_in_the_arm_form
    then_i_should_see_the_new_arm
  end

  scenario 'identity edits an existing arm on the protocol' do
    given_a_protocol_with_one_arm
    when_i_click_the_edit_arm_button
    and_then_i_change_the_arm_name
    then_i_should_see_the_updated_arm
  end

  scenario 'identity deletes an arm' do
    given_a_protocol_with_multiple_arms
    when_i_delete_the_arm
    i_should_no_longer_see_the_arm
  end

  scenario 'identity is not allowed to delete an arm with fulfillments' do
    given_a_protocol_with_multiple_arms
    and_an_arm_with_completed_procedures
    if_i_delete_the_arm_with_completed_procedures
    then_i_should_still_see_the_arm @protocol.arms.last.name
  end

  scenario 'identity is not allowed to delete the final arm on the protocol' do
    given_a_protocol_with_one_arm
    when_i_delete_the_arm
    then_i_should_still_see_the_arm
  end


  def given_a_protocol_with_one_arm
    @protocol = create_and_assign_protocol_to_me
    @protocol.arms.each do |arm|
      if @protocol.arms.count != 1
        arm.delete
      end
    end
    visit protocol_path @protocol
  end

  def given_a_protocol_with_multiple_arms
    @protocol = create_and_assign_protocol_to_me
    arm       = create(:arm, protocol: @protocol)
    visit protocol_path @protocol
  end

  def and_an_arm_with_completed_procedures
    participant  = create(:participant_with_appointments, protocol: @protocol, arm: @protocol.arms.first)
    procedure    = create(:procedure_complete, appointment: participant.appointments.first, arm: @protocol.arms.first, completed_date: "10-09-2010")
    visit protocol_path @protocol
  end

  def when_i_add_an_arm
    find("#add_arm_button").click
  end

  def and_i_fill_in_the_arm_form
    fill_in 'Arm Name', with: 'arm name'
    fill_in 'Subject Count', with: 1
    fill_in 'Visit Count', with: 3
    click_button 'Add'
  end

  def then_i_should_see_the_new_arm
    expect(find(".study_schedule_container")).to have_content "arm name"
  end

  def when_i_click_the_edit_arm_button
    find("#edit_arm_button").click
  end

  def and_then_i_change_the_arm_name
    fill_in 'Arm Name', with: "this here arm"
    find("input[type='submit']").click
  end

  def then_i_should_see_the_updated_arm
    expect(find(".study_schedule_container")).to have_content 'this here arm'
  end

  def when_i_delete_the_arm
    find("#remove_arm_button").click
    find("input[type='submit']").click
  end

  def i_should_no_longer_see_the_arm
    expect(find(".study_schedule_container")).not_to have_content @protocol.arms.first.name
  end

  def if_i_delete_the_arm_with_completed_procedures
    find("#remove_arm_button").click
    bootstrap_select "#arm_form_select", @protocol.arms.last.name
    find("input[type='submit']").click
  end

  def then_i_should_still_see_the_arm name=@protocol.arms.last.name
    expect(find(".study_schedule_container")).to have_content name
  end
end
