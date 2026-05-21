# Copyright © 2011-2023 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

require 'rails_helper'

feature 'Identity edits arms on protocol study schedule', js: true do

  context 'User adds an arm' do
    scenario 'and sees the new arm is created' do
      given_i_am_viewing_a_protocol_with_one_arm
      when_i_click_the_add_arm_button
      when_i_fill_in_the_form
      when_i_click_the_add_submit_button
      then_i_should_see_the_new_arm
    end
  end

  context 'User edits an arm' do
    scenario 'and sees the updated arm' do
      given_i_am_viewing_a_protocol_with_one_arm
      when_i_click_the_edit_arm_button
      when_i_set_the_name_to 'other arm name'
      when_i_set_the_subject_count_to 1234
      when_i_click_the_save_submit_button
      then_i_should_see_the_updated_arm
    end
  end

  context 'User deletes an arm' do
    scenario 'and does not see the arm' do
      given_i_am_viewing_a_protocol_with_multiple_arms
      when_i_click_the_remove_arm_button
      and_i_select_the_first_arm
      when_i_click_the_remove_submit_button
      then_i_should_not_see_the_arm
    end
  end

  context 'User tries to delete an arm with fulfillments' do
    scenario 'and sees the arm' do
      given_i_am_viewing_a_protocol_with_multiple_arms
      given_there_is_an_arm_with_completed_procedures
      when_i_click_the_remove_arm_button
      when_i_select_the_arm_with_completed_procedures
      when_i_click_the_remove_submit_button
      then_i_should_see_an_error_about_completed_procedures
    end
  end

  context 'User tries to delete the last arm' do
    scenario 'and sees the arm' do
      given_i_am_viewing_a_protocol_with_one_arm
      when_i_click_the_remove_arm_button
      when_i_click_the_remove_submit_button
      then_i_should_see_an_error_about_last_arm
    end
  end

  def given_i_am_viewing_a_protocol_with_one_arm
    @protocol = create_and_assign_protocol_to_me
    first_arm = @protocol.arms.first
    @protocol.arms.where.not(id: first_arm.id).destroy_all

    visit protocol_path(@protocol)

    schedule_tab = find('#studyScheduleTabLink', wait: 5)
    schedule_tab.hover
    schedule_tab.click

    expect(page).to have_css('#studyScheduleTab', wait: 5)
  end

  def given_i_am_viewing_a_protocol_with_multiple_arms
    @protocol = create_and_assign_protocol_to_me
    arm       = create(:arm, protocol: @protocol)

    visit protocol_path(@protocol)

    schedule_tab = find('#studyScheduleTabLink', wait: 5)
    schedule_tab.hover
    schedule_tab.click

    expect(page).to have_css('#studyScheduleTab', wait: 5)
  end

  def given_there_is_an_arm_with_completed_procedures
    @arm_with_procedures = @protocol.arms.first
    protocols_participant  = create(:protocols_participant_with_appointments, protocol: @protocol, arm: @arm_with_procedures, participant: create(:participant))
    procedure    = create(:procedure_complete, appointment: protocols_participant.appointments.first, arm: @arm_with_procedures, status: "complete", completed_date: Date.today.strftime('%m/%d/%Y'), service: create(:service))

    visit protocol_path(@protocol)

    schedule_tab = find('#studyScheduleTabLink', wait: 5)
    schedule_tab.hover
    schedule_tab.click

    expect(page).to have_css('#studyScheduleTab', wait: 5)
  end

  def when_i_click_the_add_arm_button
    add_btn = find('div#manage_arms .btn-success', wait: 5)
    add_btn.hover
    add_btn.click
    
    expect(page).to have_css('input[type="submit"]', wait: 5)
  end

  def when_i_click_the_remove_arm_button
    remove_btn = find('div#manage_arms .btn-danger', wait: 5)
    remove_btn.hover
    remove_btn.click
    
    expect(page).to have_css('#removeArmButton', wait: 5)
  end

  def and_i_select_the_first_arm
    @deleted_arm_name = @protocol.arms.first.name
    bootstrap_select "#arm_form_select", @deleted_arm_name
  end

  def when_i_click_the_edit_arm_button
    edit_btn = find('div#manage_arms .btn-warning', wait: 5)
    edit_btn.hover
    edit_btn.click
    
    expect(page).to have_css('input[type="submit"]', wait: 5)
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
    submit_btn = find('input[type="submit"]', wait: 5)
    submit_btn.hover
    submit_btn.click
  end

  def when_i_click_the_remove_submit_button
    remove_btn = find('#removeArmButton', wait: 5)
    remove_btn.hover
    remove_btn.click

    confirm_btn = find('button.swal2-confirm', wait: 5)
    confirm_btn.hover
    confirm_btn.click
  end

  def when_i_click_the_save_submit_button
    submit_btn = find('input[type="submit"]', wait: 5)
    submit_btn.hover
    submit_btn.click
  end

  def when_i_select_the_arm_with_completed_procedures
    bootstrap_select "#arm_form_select", @arm_with_procedures.name
  end

  def then_i_should_see_the_new_arm
    expect(page).to have_css("#studyScheduleTab", text: "arm name", wait: 5)
  end

  def then_i_should_see_an_error_about_last_arm
    expect(page).to have_content(@protocol.arms.first.name, wait: 5)
  end

  def then_i_should_see_an_error_about_completed_procedures
    expect(page).to have_content("has completed procedures and cannot be deleted", wait: 5)
  end

  def then_i_should_see_the_updated_arm
    expect(page).to have_css("#studyScheduleTab", text: "other arm name", wait: 5)
  end

  def then_i_should_not_see_the_arm
    expect(page).to_not have_css('.swal2-container', wait: 5)
    
    expect(page).to_not have_css('#removeArmButton', wait: 5)
    
    expect(find("#studyScheduleTab")).not_to have_content(@deleted_arm_name)
  end
end
