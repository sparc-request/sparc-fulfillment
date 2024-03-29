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

feature 'Followup note', js: true do

  context 'User starts an appointment' do
    scenario 'and sees the followup button' do
      given_i_have_created_a_procedure
      when_i_start_the_appointment
      then_i_should_see_the_followup_button
    end

    context 'and creates a followup' do
      scenario 'and sees the followup date' do
        given_i_have_created_a_procedure
        when_i_start_the_appointment
        when_i_click_the_followup_button
        when_i_fill_out_and_submit_the_followup_form
        then_i_should_see_a_text_field_with_the_followup_date
      end

      scenario 'and sees the note in the notes list' do
        given_i_have_created_a_procedure
        given_i_have_created_a_followup_note
        when_i_view_the_notes_list
        then_i_should_see_the_note_i_created
      end

      scenario 'and sees the new respective task on the tasks page' do
        given_i_have_created_a_procedure
        given_i_have_created_a_followup_note
        when_i_visit_the_tasks_index_page
        then_i_should_see_the_newly_created_task
      end

      context 'and edits the followup date on the calendar' do
        scenario 'and sees the followup date change' do
          given_i_have_created_a_procedure
          given_i_have_created_a_followup_note
          then_i_should_be_able_to_edit_the_followup_date
          then_i_should_see_the_date_change
        end
      end
    end
  end

  context 'User does not start an appointment' do
    scenario 'and sees the followup button' do
      given_i_have_created_a_procedure
      then_i_should_see_the_followup_button
    end

    context 'and tries to add a followup note' do
      scenario 'and sees a helpful error message' do
        given_i_have_created_a_procedure
        then_i_should_see_a_helpful_message
      end
    end
  end

  def given_i_have_created_a_procedure
    protocol    = create_and_assign_protocol_to_me
    @assignee   = Identity.first
    protocols_participant = protocol.protocols_participants.first
    visit_group = protocols_participant.appointments.first.visit_group
    service     = protocol.organization.inclusive_child_services(:per_participant).first

    visit calendar_protocol_participant_path(id: protocols_participant.id, protocol_id: protocol)
    wait_for_ajax

    first('a.list-group-item.appointment-link').click
    wait_for_ajax

    add_a_procedure(service)

    @procedure = visit_group.appointments.first.procedures.where(service_id: service.id).first
  end

  def given_i_have_created_a_followup_note
    when_i_start_the_appointment
    when_i_click_the_followup_button
    when_i_fill_out_and_submit_the_followup_form
  end

  def when_i_start_the_appointment
    find('a.start-appointment').click
    wait_for_ajax
  end

  def when_i_click_the_followup_button
    find("td.followup div#followup#{@procedure.id}").click
  end

  def when_i_fill_out_and_submit_the_followup_form
    bootstrap_select '#task_assignee_id', @assignee.full_name
    bootstrap_datepicker '#task_due_at', day: '10'
    fill_in 'Comment', with: 'Test comment'
    find('input[type="submit"]').click
    wait_for_ajax
  end

  def when_i_view_the_notes_list
    find("div#procedure#{@procedure.id}Notes a.btn").click
  end

  def when_i_visit_the_tasks_index_page
    visit tasks_path
    wait_for_ajax
  end

  def when_i_try_to_add_a_follow_up_note
    find("td.followup div#followup#{@procedure.id}").click
    alert = page.driver.browser.switch_to.alert
    @alert_message = alert.text
    alert.accept
    wait_for_ajax
  end

  def then_i_should_see_the_followup_button
    expect(page).to have_css("td.followup div#followup#{@procedure.id}")
  end

  def then_i_should_see_a_text_field_with_the_followup_date
    expect(page).to have_css("input#followupDatePickerInput#{@procedure.id}[value='#{Time.new(Time.now.year,Time.now.month,10).strftime("%m/%d/%Y")}']")
  end

  def then_i_should_see_the_note_i_created
    expect(page).to have_css('.note-body p', text: "Followup: #{@procedure.task.due_at.strftime("%Y-%m-10")}: Test comment")
  end

  def then_i_should_see_the_newly_created_task
    expect(page).to have_css("tr td.w-31", text: "Test comment")
  end

  def then_i_should_be_able_to_edit_the_followup_date
    bootstrap_datepicker "#followupDatePickerInput#{@procedure.id}", day: '15'
  end

  def then_i_should_see_the_date_change
    expect(@procedure.task.due_at.strftime("%m/%d/%Y")).to eq Time.new(Time.now.year,Time.now.month,15).strftime("%m/%d/%Y")
  end

  def then_i_should_see_a_helpful_message
    expect(page).to have_css("div#procedure#{@procedure.id}StatusButtons[data-original-title=\"Click \'Start Visit\' and enter a start date to continue.\"]", visible: false)
  end
end
