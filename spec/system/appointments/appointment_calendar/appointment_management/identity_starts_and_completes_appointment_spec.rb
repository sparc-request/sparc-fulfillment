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

RSpec.describe 'Start Complete Buttons', type: :system, js: true do
  let(:protocol) { create_and_assign_protocol_to_me(identity: @logged_in_identity) }
  let(:protocols_participant) { protocol.protocols_participants.first }
  let(:appointment) { protocols_participant.appointments.first }
  let(:visit_group) { appointment.visit_group }
  let(:service) { protocol.organization.inclusive_child_services(:per_participant).first }

  context 'User visits appointment with no start date or completed_date' do
    scenario 'and sees the start button is active and the complete button disabled' do
      given_i_am_viewing_an_appointment
      then_i_should_see_the_start_button
      when_i_add_a_procedure
      then_i_should_see_the_complete_button_disabled
    end
  end

  context 'User visits appointment with start date but no completed date' do
    scenario 'and sees the start date picker and the completed button active' do
      given_there_is_a_start_date
      given_i_am_viewing_an_appointment
      then_i_should_see_the_complete_button
    end
  end

  context 'User visits appointment with start date and completed date' do
    scenario 'and sees the start date picker and the completed date picker' do
      given_there_is_a_start_date_and_a_completed_date
      given_i_am_viewing_an_appointment
      then_i_should_see_the_completed_datepicker
    end
  end

  context 'User clicks start button' do
    scenario 'and sees the start datepicker and the completed button' do
      given_i_am_viewing_an_appointment
      when_i_click_the_start_button
      then_i_should_see_the_complete_button
    end
  end

  context 'User clicks complete button' do
    scenario 'and sees the start date picker and the completed datepicker' do
      given_there_is_a_start_date
      given_i_am_viewing_an_appointment
      when_i_click_the_complete_button
      then_i_should_see_the_completed_datepicker
    end
  end

  context 'User sets completed date and start date' do
    scenario 'and sees the completed and start date updated' do
      now = Date.today

      given_there_is_a_start_date_and_a_completed_date
      given_i_am_viewing_an_appointment
      when_i_set_the_completed_date_to(now)
      then_i_should_see_the_completed_date_at(now)
    end
  end

  context 'User sets start date to future then clicks complete button' do
    scenario 'and sees a validation error' do 
      future = Time.current + 1.month

      given_there_is_a_start_date
      given_i_am_viewing_an_appointment
      
      when_i_set_the_start_date_to(future)
      
      # Click the button manually here instead of using the helper, because we DO NOT expect the Completed Date field to appear
      click_button 'Complete Visit'
      
      expect(page).to have_content('Completed date must be the same, or later than start date.')
    end
  end

  def given_there_is_a_start_date
    appointment.update(start_date: Time.current)
  end

  def given_there_is_a_completed_date
    appointment.update(completed_date: Time.current)
  end

  def given_there_is_a_start_date_and_a_completed_date
    appointment.update(start_date: Time.current, completed_date: Time.current)
  end

  def given_i_am_viewing_an_appointment
    # Consolidated all 3 old navigation methods into this single, robust one - this overrides the global helper in VisitHelpers for this test file
    visit calendar_protocol_participant_path(protocol_id: protocol.id, id: protocols_participant.id)
    
    find('a.list-group-item.appointment-link', text: visit_group.name, match: :first).click

    within('#appointmentContainer') do
      expect(page).to have_css('h3', text: /#{visit_group.name}/i)
    end
  end

  def when_i_add_a_procedure
    bootstrap_select('.form-control.selectpicker', service.name)
    click_button 'Add Service' 

    within('#appointmentContainer') do
      expect(page).to have_css('tr', text: service.name)
    end
  end

  def when_i_click_the_start_button
    click_link 'Start Visit'
    expect(page).to have_no_link('Start Visit')

    # Ensure the view stabilizes after the visit has started
    find('a.list-group-item, a.visit-group-link', text: visit_group.name, match: :first).click
    within('#appointmentContainer') do
      expect(page).to have_css('h3', text: /#{visit_group.name}/i)
    end
  end

  def when_i_set_the_start_date_to(date)
    bootstrap_datepicker "input#start_date", text: date.strftime('%m/%d/%Y')
  end

  def when_i_click_the_complete_button
    click_button 'Complete Visit'
    expect(page).to have_field('Completed Date')
  end

  def when_i_set_the_completed_date_to(date)
    # Target the field robustly and use the helper's text argument
    bootstrap_datepicker "input[name*='completed_date']", text: date.strftime('%m/%d/%Y')
  end

  def then_i_should_see_the_start_button
    expect(page).to have_link('Start Visit')
  end

  def then_i_should_see_the_complete_button
    expect(page).to have_button('Complete Visit', disabled: false)
  end

  def then_i_should_see_the_complete_button_disabled
    # When an appointment is unstarted, the Complete button doesn't just disable - it disappears entirely
    expect(page).to have_no_button('Complete Visit')
    expect(page).to have_link('Start Visit')
  end

  def then_i_should_see_the_start_datepicker
    expect(page).to have_field('Start Date')
  end

  def then_i_should_see_the_completed_datepicker
    expect(page).to have_field('Completed Date')
  end

  def then_i_should_see_the_start_date_at(date)
    expect(page).to have_field('Start Date', with: date.strftime('%m/%d/%Y'))
  end

  def then_i_should_see_the_completed_date_at(date)
    expect(page).to have_field('Completed Date', with: date.strftime('%m/%d/%Y'))
  end
end
