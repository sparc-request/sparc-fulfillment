# Copyright © 2011-2020 MUSC Foundation for Research Development~
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
      # Ensure that the selected arm is the correct one being deleted
      bootstrap_select "#arm_form_select", @protocol.arms.first.name
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
      when_i_click_the_close_submit_button
      then_i_should_still_see_the_arm
    end
  end

  # context 'User tries to delete the last arm' do
  #   scenario 'and sees the arm' do
  #     given_i_am_viewing_a_protocol_with_one_arm
  #     when_i_click_the_remove_arm_button
  #     when_i_click_the_remove_submit_button
  #     when_i_click_the_close_submit_button
  #     then_i_should_still_see_the_arm
  #   end
  # end


  def given_i_am_viewing_a_protocol_with_one_arm
    @protocol = create_and_assign_protocol_to_me

    visit protocol_path @protocol
    wait_for_ajax

    find('#studyScheduleTabLink').click
    wait_for_ajax
  end

  def given_i_am_viewing_a_protocol_with_multiple_arms
    @protocol = create_and_assign_protocol_to_me
    arm       = create(:arm, protocol: @protocol)

    visit protocol_path @protocol
    wait_for_ajax

    find('#studyScheduleTabLink').click
    wait_for_ajax
  end


  def given_there_is_an_arm_with_completed_procedures
    protocols_participant  = create(:protocols_participant_with_appointments, protocol: @protocol, arm: @protocol.arms.first, participant: create(:participant))
    procedure    = create(:procedure_complete, appointment: protocols_participant.appointments.first, arm: @protocol.arms.first, status: "complete", completed_date: Date.today.strftime('%m/%d/%Y'), service: create(:service))

    visit protocol_path @protocol
    wait_for_ajax
  end

  def when_i_click_the_add_arm_button
    find('div#manage_arms .btn-success').click
    wait_for_ajax
  end

  def when_i_click_the_remove_arm_button
    find('div#manage_arms .btn-danger').click
    wait_for_ajax
  end

  def when_i_click_the_edit_arm_button
    find('div#manage_arms .btn-warning').click
    wait_for_ajax
  end

  def when_i_fill_in_the_form
    fill_in 'Arm Name', with: 'arm name'
    wait_for_ajax
    fill_in 'Subject Count', with: 1
    wait_for_ajax
    fill_in 'Visit Count', with: 3
    wait_for_ajax
  end

  def when_i_set_the_name_to name
    fill_in 'Arm Name', with: name
    wait_for_ajax
  end

  def when_i_set_the_subject_count_to count
    fill_in 'Subject Count', with: count
    wait_for_ajax
  end

  def when_i_click_the_add_submit_button
    wait_for_ajax
    find('input[type="submit"]').click
    wait_for_ajax
  end

  def when_i_click_the_remove_submit_button
    find('#removeArmButton').click
    find('button.swal2-confirm').click
    wait_for_ajax
  end

  def when_i_click_the_save_submit_button
    find('input[type="submit"]').click
    wait_for_ajax
  end

  def when_i_click_the_close_submit_button
    click_button "Close"
    wait_for_ajax
  end

  def when_i_select_the_arm_with_completed_procedures
    bootstrap_select "#arm_form_select", @protocol.arms.first.name
  end

  def then_i_should_see_the_new_arm
    sleep 2
    expect(find("#studyScheduleTab")).to have_content "arm name"
  end

  def then_i_should_see_the_updated_arm
    expect(find("#studyScheduleTab")).to have_content "other arm name"
  end

  def then_i_should_not_see_the_arm
    expect(find("#studyScheduleTab")).not_to have_content @protocol.arms.first.name #The first arm is gone
  end

  def then_i_should_still_see_the_arm
    expect(find("#studyScheduleTab")).to have_content @protocol.arms.last.name #The last arm (with procedures) is gone
  end
end
