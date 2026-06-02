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

RSpec.describe 'Identity creates custom appointment', type: :system, js: true do
  let!(:protocol)              { create_and_assign_protocol_to_me }
  let!(:protocols_participant) { protocol.protocols_participants.first }
  let!(:service)               { protocol.organization.inclusive_child_services(:per_participant).first }
  let(:custom_visit_name)      { 'Test Visit' }

  context 'User tries to create a custom appointment' do
    context 'and the participant has an arm' do
      before do
        protocols_participant.update(arm: Arm.last || create(:arm))
      end

      scenario 'and sees the create custom visit modal' do
        given_i_am_viewing_the_participant_calendar
        when_i_click_create_custom_appointment
        then_i_should_see_the_create_custom_visit_modal
      end
    end
  end

  context 'User creates custom appointment' do
    before do
      protocols_participant.update(arm: Arm.last || create(:arm))
    end

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

  def given_i_am_viewing_the_participant_calendar
    visit calendar_protocol_participant_path(id: protocols_participant.id, protocol_id: protocol.id)
    
    expect(page).to have_css('#appointmentContainer', visible: :all)
  end

  def when_i_click_create_custom_appointment
    find('#new_appointment_button').click
  end

  def when_i_fill_in_the_form
    # Strict targeting: Blind Capybara to the rest of the page to prevent false positive matches
    within('.modal') do
      fill_in 'custom_visit_name', with: custom_visit_name
      bootstrap_select '#custom_visit_position', 'Add as last'
      bootstrap_select '#custom_visit_reason', 'Assessment not performed'
    end
  end

  def when_i_click_add_appointment
    within('.modal') do
      click_button 'Submit'
    end
    
    expect(page).to have_no_css('.modal')
  end

  def when_i_select_the_appointment
    retries = 5
    begin
      find('a.appointment-link span', text: custom_visit_name, match: :first).click
    rescue Selenium::WebDriver::Error::StaleElementReferenceError
      retries -= 1
      retry if retries > 0
      raise "StaleElementReferenceError exhausted targeting the newly created custom appointment link"
    end

    expect(page).to have_button('addService', disabled: :all)
  end

  def when_i_add_a_procedure
    add_a_procedure(service: service)
  end

  def when_i_complete_the_procedure
    start_btn = find('a.start-appointment, button.start-appointment', match: :first)
    start_btn.click
    
    expect(page).to have_no_css('a.start-appointment, button.start-appointment')
    expect(page).to have_css('button.complete-appointment', visible: :all)

    find('button.complete-btn', match: :first).click
    
    expect(page).to have_css('button.complete-btn.active')

    find('button.complete-appointment').click
  end

  def then_i_should_see_the_create_custom_visit_modal
    expect(page).to have_css('.modal-title', text: 'Custom Visit', visible: true)
  end

  def then_i_should_see_the_newly_created_appointment
    expect(page).to have_css('a.appointment-link span', text: custom_visit_name, visible: :all)
  end

  def then_it_should_appear_on_the_dashboard
    expect(page).to have_content(custom_visit_name)
    expect(page).to have_content(service.name)
  end
end
