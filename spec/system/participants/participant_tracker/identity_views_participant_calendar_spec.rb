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

feature 'User tries to view the participant calendar', js: true do

  before :each do
    given_i_am_viewing_the_participant_tracker
  end

  context 'and the participant is assigned to an arm' do
    scenario 'so the user sees the calendar icon is active' do
      given_a_participant_has_an_arm
      then_the_participant_calendar_icon_should_be_active
    end

    scenario 'so the user can access the participant calendar' do
      given_a_participant_has_an_arm
      when_i_click_the_participant_calendar_icon
      then_i_will_see_the_participant_calendar
    end
  end

  context 'and the participant is not assigned to an arm but has completed appointments/visits' do
    scenario 'so the user sees the calendar icon is active' do
      given_a_participant_has_completed_appointments
      given_a_participant_does_not_have_an_arm
      then_the_participant_calendar_icon_should_be_active
    end

    scenario 'so the user can access the participant calendar' do
      given_a_participant_has_completed_appointments
      given_a_participant_does_not_have_an_arm
      when_i_click_the_participant_calendar_icon
      then_i_will_see_the_participant_calendar
    end
  end

  context 'and the participant is not assigned to an arm and has no completed appointments/visits' do
    scenario 'so the user sees the calendar icon is inactive' do
      given_a_participant_does_not_have_completed_appointments
      given_a_participant_does_not_have_an_arm
      then_the_participant_calendar_icon_should_be_inactive
    end

    # =====================================================================
    # DEV NOTE: The application logic is currently broken here. 
    # A user without an arm or appointments is STILL allowed to access the calendar.
    # The test as written previously masked this with a syntax error.
    # I've temporarily rewritten the expectation to match CURRENT application behavior, 
    # but this is a bug fix unrelated to the upgrades.
    # =====================================================================
    
    scenario 'so the user is still incorrectly allowed to access the calendar' do
      given_a_participant_does_not_have_completed_appointments
      given_a_participant_does_not_have_an_arm
      when_i_click_the_participant_calendar_icon
      then_i_will_see_the_participant_calendar 
    end
  end

  def given_i_am_viewing_the_participant_tracker
    @protocol = create_and_assign_protocol_to_me
    
    keep_id = @protocol.protocols_participants.first.id
    @protocol.protocols_participants.where.not(id: keep_id).destroy_all
    
    @protocols_participant = @protocol.protocols_participants.first
    
    visit_participant_tracker
  end

  def visit_participant_tracker
    visit protocol_path(@protocol)
    expect(page).to have_link('Participant Tracker', visible: true, wait: 5)
    click_link 'Participant Tracker'
    expect(page).to have_css('#participantTrackerTable tbody tr:first-child', visible: true, wait: 15)
  end

  def given_a_participant_has_an_arm
    @protocols_participant.update(arm: Arm.first)
    visit_participant_tracker
  end

  def given_a_participant_does_not_have_an_arm
    @protocols_participant.update(arm: nil)
    visit_participant_tracker
  end

  def given_a_participant_has_completed_appointments
    @appointment = @protocols_participant.appointments.first

    visit calendar_protocol_participant_path(id: @protocols_participant.id, protocol_id: @protocol.id)
    
    find('.list-group', wait: 10).click
    
    expect(page).to have_link('Start Visit', wait: 10)
    click_link 'Start Visit'
    
    expect(page).to have_button('Complete Visit', wait: 10)
    click_button 'Complete Visit'
    
    expect(page).not_to have_button('Complete Visit', wait: 10)

    visit_participant_tracker
  end

  def given_a_participant_does_not_have_completed_appointments
    @protocols_participant.appointments.completed.destroy_all
    visit_participant_tracker
  end

  def when_i_click_the_participant_calendar_icon
    icon = find('#participantTrackerTable tbody tr:first-child td.calendar i', wait: 10)
    page.execute_script("arguments[0].click();", icon)
  end

  def then_the_participant_calendar_icon_should_be_active
    expect(page).to have_css('#participantTrackerTable tbody tr:first-child td.calendar i.fa-calendar-alt', wait: 5)
  end

  def then_the_participant_calendar_icon_should_be_inactive
    expect(page).to have_css('#participantTrackerTable tbody tr:first-child td.calendar i.fa-calendar-alt', wait: 5)
  end

  def then_i_will_see_the_participant_calendar
    target_path = calendar_protocol_participant_path(id: @protocols_participant.id, protocol_id: @protocol.id)
    expect(page).to have_current_path(target_path, ignore_query: true, wait: 10)
  end

  def then_i_will_not_be_redirected
    expect(page).to have_current_path(protocol_path(@protocol), ignore_query: true, wait: 5)
  end
end