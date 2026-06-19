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

RSpec.describe 'Identity edits arms on protocol study schedule', type: :system, js: true do
  let(:identity) { @logged_in_identity }
  let(:protocol) { create_and_assign_protocol_to_me(identity: identity) }
  let(:first_arm) { protocol.arms.first }

  describe 'adding an arm' do
    it 'should create and display the new arm' do
      given_i_am_viewing_the_study_schedule
      when_i_open_the_add_arm_modal
      and_i_fill_in_the_new_arm_form(name: 'Brand New Arm')
      then_i_should_see_the_arm_in_the_schedule('Brand New Arm')
    end
  end

  describe 'editing an arm' do
    it 'should update and display the updated arm' do
      given_i_am_viewing_the_study_schedule
      when_i_open_the_edit_arm_modal
      and_i_update_the_arm_details(name: 'Updated Arm Name')
      then_i_should_see_the_arm_in_the_schedule('Updated Arm Name')
    end
  end

  describe 'deleting an arm' do
    # Create a second arm strictly so the app permits deleting the first one
    let!(:second_arm) { create(:arm, protocol: protocol, name: 'Survivor Arm') }

    it 'should successfully remove the arm from the schedule' do
      given_i_am_viewing_the_study_schedule
      when_i_open_the_remove_arm_modal
      and_i_remove_the_target_arm(first_arm.name)
      then_i_should_not_see_the_arm(first_arm.name)
    end
  end

  describe 'trying to delete an arm with fulfillments' do
    # Create a second arm strictly so the app permits attempting to delete the first one
    let!(:second_arm) { create(:arm, protocol: protocol, name: 'Survivor Arm') }

    it 'should display an error preventing deletion' do
      given_there_is_an_arm_with_completed_procedures(first_arm)
      given_i_am_viewing_the_study_schedule
      when_i_open_the_remove_arm_modal
      and_i_attempt_to_remove_an_invalid_arm(first_arm.name)
      then_i_should_see_an_error_about_completed_procedures
    end
  end

  describe 'trying to delete the last arm' do
    before do
      # The factory creates multiple arms by default, explicitly destroy the others so this is truly the last arm
      protocol.arms.where.not(id: first_arm.id).destroy_all
    end

    it 'should prevent the user from deleting the only remaining arm' do
      given_i_am_viewing_the_study_schedule
      when_i_open_the_remove_arm_modal
      and_i_attempt_to_remove_an_invalid_arm(first_arm.name)
      then_the_last_arm_should_not_be_deleted(first_arm.name)
    end
  end

  def given_i_am_viewing_the_study_schedule
    visit protocol_path(protocol)
    expect(page).to have_css('div#manage_arms', visible: true)
  end

  def given_there_is_an_arm_with_completed_procedures(target_arm)
    participant = create(:participant)
    protocols_participant = create(:protocols_participant_with_appointments, protocol: protocol, arm: target_arm, participant: participant)
    appointment = protocols_participant.appointments.first

    # Letting the factory handle status, service, and dates natively to bypass Date/Pricing Map validations
    create(:procedure_complete, appointment: appointment, arm: target_arm)
  end

  def when_i_open_the_add_arm_modal
    within('div#manage_arms') do
      find('.btn-success').click
    end
    expect(page).to have_css('.modal-title', text: /Add Arm/i, visible: true)
  end

  def when_i_open_the_edit_arm_modal
    within('div#manage_arms') do
      find('.btn-warning').click
    end
    expect(page).to have_css('.modal-title', text: /Edit Arm/i, visible: true)
  end

  def when_i_open_the_remove_arm_modal
    within('div#manage_arms') do
      find('.btn-danger').click
    end
    expect(page).to have_css('.modal-title', text: /Remove Arm/i, visible: true)
  end

  def and_i_fill_in_the_new_arm_form(name:)
    within('.modal-content', text: /Add Arm/i) do
      fill_in 'Arm Name', with: name
      fill_in 'Subject Count', with: '1'
      fill_in 'Visit Count', with: '3'
      
      find('input[type="submit"]').click
    end
    
    expect(page).to have_no_css('.modal-content', text: /Add Arm/i)
  end

  def and_i_update_the_arm_details(name:)
    within('.modal-content', text: /Edit Arm/i) do
      fill_in 'Arm Name', with: name
      fill_in 'Subject Count', with: '1234'
      
      find('input[type="submit"]').click
    end
    
    expect(page).to have_no_css('.modal-content', text: /Edit Arm/i)
  end

  def and_i_remove_the_target_arm(arm_name)
    within('.modal-content', text: /Remove Arm/i) do
      bootstrap_select('#arm_form_select', arm_name)
      find('#removeArmButton').click
    end

    expect(page).to have_css('.swal2-container', visible: true)
    
    within('.swal2-container') do
      find('button.swal2-confirm').click
    end

    expect(page).to have_no_css('.swal2-container')
    expect(page).to have_no_css('.modal-content', text: /Remove Arm/i)
  end

  def and_i_attempt_to_remove_an_invalid_arm(arm_name)
    within('.modal-content', text: /Remove Arm/i) do
      bootstrap_select('#arm_form_select', arm_name)
      find('#removeArmButton').click
    end

    expect(page).to have_css('.swal2-container', visible: true)
    
    within('.swal2-container') do
      find('button.swal2-confirm').click
    end

    expect(page).to have_no_css('.swal2-container')
  end

  def then_i_should_see_the_arm_in_the_schedule(arm_name)
    expect(page).to have_css('#studyScheduleTab', text: /#{Regexp.quote(arm_name)}/i, visible: true)
  end

  def then_i_should_not_see_the_arm(arm_name)
    expect(page).to have_no_css('#studyScheduleTab', text: /#{Regexp.quote(arm_name)}/i)
  end

  def then_i_should_see_an_error_about_completed_procedures
    expect(page).to have_css('.modal-body', text: /has completed procedures and cannot be deleted/i, visible: true)
  end

  def then_the_last_arm_should_not_be_deleted(arm_name)
    expect(page).to have_css('#studyScheduleTab', text: /#{Regexp.quote(arm_name)}/i, visible: true)
  end
end