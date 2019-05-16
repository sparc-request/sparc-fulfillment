# Copyright © 2011-2019 MUSC Foundation for Research Development~
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

feature 'Custom appointment', js: true do

  context 'User tries to create a custom appointment' do
    context 'and the participant has an arm' do
      scenario 'and sees the create custom visit modal' do
        given_i_am_viewing_the_participant_calendar(:with_arm)
        when_i_click_create_custom_appointment
        then_i_should_see_the_create_custom_visit_modal
      end
    end

    context 'and the participant does not have an arm' do
      scenario 'and does not see the create custom visit modal' do
        given_i_am_viewing_the_participant_calendar(:without_arm)
        when_i_click_create_custom_appointment
        then_i_should_not_see_the_create_custom_visit_modal
      end
    end
  end

  context 'User creates custom appointment' do
    context 'and saves after correctly filling out the form' do
      scenario 'and sees the new appointment' do
        given_i_am_viewing_the_participant_calendar
        when_i_click_create_custom_appointment
        when_i_fill_in_the_form
        when_i_click_add_appointment
        then_i_should_see_the_newly_created_appointment
      end
    end

    context 'and adds a procedure to the appointment' do
      scenario 'and sees the procedure' do
        given_i_am_viewing_the_participant_calendar
        when_i_click_create_custom_appointment
        when_i_fill_in_the_form
        when_i_click_add_appointment
        when_i_select_the_appointment
        when_i_add_a_procedure
        when_i_complete_the_procedure
        then_it_should_appear_on_the_dashboard
      end
    end
  end

  def given_i_am_viewing_the_participant_calendar(has_arm=:with_arm)
    @protocol     = create_and_assign_protocol_to_me
    @protocols_participant  = @protocol.protocols_participants.first

    case has_arm
    when :with_arm
      @protocols_participant.update_attribute(:arm, Arm.first)
    when :without_arm
      @protocols_participant.update_attribute(:arm, nil)
    end

    visit calendar_participants_path(participant_id: @protocols_participant.participant_id, protocols_participant_id: @protocols_participant.id, protocol_id: @protocol)
    wait_for_ajax
  end

  def when_i_click_create_custom_appointment
    find('button.appointment.new').click
  end

  def when_i_fill_in_the_form
    fill_in 'custom_appointment_name', with: 'Test Visit'
    bootstrap_select "#custom_appointment_position", "Add as last"
    bootstrap_select "#custom_appointment_notes_attributes_0_reason", "Assessment not performed"
  end

  def when_i_click_add_appointment
    click_button 'Add'
    wait_for_ajax
  end

  def when_i_select_the_appointment
    @service = @protocol.organization.inclusive_child_services(:per_participant).first
    @service.update_attributes(name: 'Test Service')
    bootstrap_select '#appointment_select', "Test Visit"
    wait_for_ajax
  end

  def when_i_add_a_procedure
    bootstrap_select '#service_list', 'Test Service'
    fill_in 'service_quantity', with: 1
    find('button.add_service').click
    wait_for_ajax
  end

  def when_i_complete_the_procedure
    find('button.start_visit').click
    find('label.status.complete').click
    wait_for_ajax

    click_button 'Complete Visit'
    wait_for_ajax
  end

  def then_i_should_see_the_create_custom_visit_modal
    expect(page).to have_css("body.participants.modal-open")
  end

  def then_i_should_see_the_create_custom_visit_button_is_disabled
  end

  def then_i_should_not_see_the_create_custom_visit_modal
    expect(page).to_not have_css("body.participants.modal-open")
  end

  def then_i_should_see_the_newly_created_appointment
    expect(page).to have_css("#appointment_select option", visible: false, text: "Test Visit")
  end

  def then_it_should_appear_on_the_dashboard
    expect(page).to have_content('Test Visit')
  end
end
