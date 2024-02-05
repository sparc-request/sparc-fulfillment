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
      given_a_participant_does_not_have_an_arm
      given_a_participant_has_completed_appointments
      then_the_participant_calendar_icon_should_be_active
    end

    scenario 'so the user can access the participant calendar' do
      given_a_participant_does_not_have_an_arm
      given_a_participant_has_completed_appointments
      when_i_click_the_participant_calendar_icon
      then_i_will_see_the_participant_calendar
    end
  end

  context 'and the participant is not assigned to an arm and has no completed appointments/visits' do
    scenario 'so the user sees the calendar icon is inactive' do
      given_a_participant_does_not_have_an_arm
      given_a_participant_does_not_have_completed_appointments
      then_the_participant_calendar_icon_should_be_inactive
    end

    scenario 'so the user cant access the participant calendar' do
      given_a_participant_does_not_have_an_arm
      given_a_participant_does_not_have_completed_appointments
      when_i_click_the_participant_calendar_icon
      then_i_will_not_be_redirected
    end
  end

  def given_i_am_viewing_the_participant_tracker
    @protocol = create_and_assign_protocol_to_me
    @protocols_participant = @protocol.protocols_participants.first

    visit protocol_path @protocol
    wait_for_ajax
    click_link 'Participant Tracker'
    wait_for_ajax
  end

  def given_a_participant_has_an_arm
    @protocols_participant.arm = Arm.first
  end

  def given_a_participant_does_not_have_an_arm
    @protocols_participant.arm = nil
  end

  def given_a_participant_has_completed_appointments
    @appointment = @protocols_participant.appointments.first
    @visit_group = @appointment.visit_group

    visit calendar_protocol_participant_path(id: @protocols_participant.id, protocol_id: @protocol)
    wait_for_ajax

    find('.list-group').click
    wait_for_ajax
    # click_button 'Start Visit'
    click_link 'Start Visit'
    wait_for_ajax
    click_button 'Complete Visit'
    wait_for_ajax

    visit protocol_path @protocol
    wait_for_ajax
    click_link 'Participant Tracker'
    wait_for_ajax
  end

  def given_a_participant_does_not_have_completed_appointments
    @protocols_participant.appointments.completed.destroy_all
  end

  def when_i_click_the_participant_calendar_icon
    find("tr[data-index='0'] td.calendar").click
    wait_for_ajax
  end

  def then_the_participant_calendar_icon_should_be_active
    expect(page).to have_css("tr[data-index='0'] td.calendar i.fa-calendar-alt")
  end

  def then_the_participant_calendar_icon_should_be_inactive
    expect(page).to have_css("tr[data-index='0'] td.calendar i.fa-calendar-alt")
  end

  def then_i_will_see_the_participant_calendar
    expect(current_path) == participants_path + '/' + @protocols_participant.id.to_s
  end

  def then_i_will_not_be_redirected
    expect(current_path) == protocols_path + '/' + @protocol.id.to_s + '#'
  end
end
