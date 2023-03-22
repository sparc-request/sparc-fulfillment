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

feature 'Start Complete Buttons', js: true do

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
      given_i_am_viewing_an_appointment
      given_there_is_a_start_date
      when_i_load_the_page_and_select_a_visit
      then_i_should_see_the_complete_button
    end
  end

  context 'User visits appointment with start date and completed date' do
    scenario 'and sees the start date picker and the completed date picker' do
      given_i_am_viewing_an_appointment
      given_there_is_a_start_date_and_a_completed_date
      when_i_load_the_page
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
      given_i_am_viewing_an_appointment
      given_there_is_a_start_date
      when_i_load_the_page_and_select_a_visit
      when_i_click_the_complete_button
      then_i_should_see_the_completed_datepicker
    end
  end

  context 'User sets completed date and start date' do
    scenario 'and sees the completed and start date updated' do
      now = Date.today

      given_i_am_viewing_an_appointment
      given_there_is_a_start_date_and_a_completed_date
      when_i_load_the_page
      when_i_set_the_completed_date_to now
      then_i_should_see_the_completed_date_at now
    end
  end

  context 'User sets start date to future then clicks complete button' do
    scenario 'and sees the completed date updated' do
      future = Time.current + 1.month

      given_i_am_viewing_an_appointment
      given_there_is_a_start_date
      when_i_load_the_page_and_select_a_visit
      when_i_click_the_complete_button
      then_i_should_see_the_completed_date_at future
    end
  end

  def given_i_am_viewing_an_appointment
    @protocol    = create_and_assign_protocol_to_me
    @protocols_participant = @protocol.protocols_participants.first
    @appointment = @protocols_participant.appointments.first
    @visit_group = @appointment.visit_group

    visit calendar_protocol_participant_path(protocol_id: @protocol.id, id: @protocols_participant.id)
    wait_for_ajax
    
    find('div.list-group-flush a:nth-child(1)').click
    wait_for_ajax
  end

  def when_i_add_a_procedure
    visit_group = @protocols_participant.appointments.first.visit_group
    service     = @protocol.organization.inclusive_child_services(:per_participant).first

    first('a.list-group-item.appointment-link').click
    bootstrap_select('.form-control.selectpicker', service.name)
    page.find('button#addService').click
    wait_for_ajax
  end

  def given_there_is_a_start_date
    @appointment.start_date = Time.current
    @appointment.save
    @appointment.reload
  end

  def given_there_is_a_completed_date
    @appointment.completed_date = Time.current
    @appointment.save
    @appointment.reload
  end

  def given_there_is_a_start_date_and_a_completed_date
    given_there_is_a_start_date
    given_there_is_a_completed_date
  end

  def when_i_load_the_page
    visit calendar_protocol_participant_path(id: @protocols_participant.id, protocol_id: @protocol.id)
    wait_for_ajax

    find('div.list-group-flush a:nth-child(1)').click
    wait_for_ajax
  end

  def when_i_load_the_page_and_select_a_visit
    visit calendar_protocol_participant_path(id: @protocols_participant.id, protocol_id: @protocol.id)
    wait_for_ajax

    find('div.list-group-flush a:nth-child(1)').click
    wait_for_ajax
  end

  def when_i_click_the_start_button
    find('a.btn.start-appointment').click
    wait_for_ajax
  end

  def when_i_click_the_complete_button
    click_button 'Complete Visit'
    wait_for_ajax
  end

  def when_i_set_the_completed_date_to date
    bootstrap_datepicker '#completed_date', date: "#{Date.today}"
  end

  def then_i_should_see_the_start_button
    expect(page).to have_css('a.start-appointment', visible: true)
    find('a.start-appointment').click
    wait_for_ajax
  end

  def then_i_should_see_the_complete_button
    expect(page).to have_css('button.btn-success.complete-appointment', visible: true)
  end

  def then_i_should_see_the_complete_button_disabled
    expect(page).to have_css('button.complete-appointment.disabled', visible: true)
  end

  def then_i_should_see_the_start_datepicker
    sleep 60
    expect(page).to have_css('input#start_date', visible: true)
  end

  def then_i_should_see_the_completed_datepicker
    expect(page).to have_css('input#completed_date', visible: true)
  end

  def then_i_should_see_the_start_date_at date
    find('input#start_date').click
    expect(page).to have_css('td.day.active', text: "#{date.day}")
  end

  def then_i_should_see_the_completed_date_at date
    find('#completed_date')
    expected_date = page.evaluate_script %Q{ $('#completed_date').first().val(); }
    expect(expected_date.split().first).to eq(Date.today.strftime('%m/%d/%Y'))
  end
end
