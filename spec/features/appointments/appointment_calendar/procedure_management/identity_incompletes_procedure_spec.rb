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

feature 'Incomplete Procedure', js: true do

  context 'User starts an appointment' do
    context 'and marks a procedure as incomplete once' do

      scenario 'and sees a single incomplete note' do
        given_i_am_viewing_an_appointment_with_a_procedure
        when_i_begin_the_appointment
        when_i_incomplete_the_procedure
        when_i_view_the_notes_list
        then_i_should_see_one_incomplete_note
      end
    end

    context 'and attempts to mark a procedure as incomplete without selecting a reason' do
      scenario 'and sees some errors' do
        given_i_am_viewing_an_appointment_with_a_procedure
        when_i_begin_the_appointment
        when_i_click_the_incomplete_button
        when_i_save_the_incomplete
        then_i_should_see_errors
      end
    end

    context 'and marks a complete procedure as incomplete and selects a reason' do
      scenario 'and sees a complete note and an incomplete note' do
        given_i_am_viewing_a_procedure_marked_as_complete
        when_i_incomplete_the_procedure
        when_i_view_the_notes_list
        then_i_should_see_one_complete_note_and_one_incomplete_note
      end
      
      scenario 'and sees they are the performer' do
        given_i_am_viewing_a_procedure_marked_as_complete
        when_i_incomplete_the_procedure
        then_i_should_see_that_i_am_the_procedure_performer
      end
    end

    context 'and marks a complete procedure as incomplete and then cancels' do
      scenario 'and sees that the procedure status is the same' do
        given_i_am_viewing_an_appointment_with_a_procedure
        when_i_begin_the_appointment
        when_i_click_the_incomplete_button
        when_i_cancel_the_incomplete
        then_i_should_see_that_the_procedure_status_has_been_reset
      end
    end

    context 'and marks a procedure as incomplete, then complete, then incomplete again' do
      scenario 'and sees two incomplete notes' do
        given_i_am_viewing_an_appointment_with_a_procedure
        when_i_begin_the_appointment
        when_i_incomplete_the_procedure
        when_i_complete_the_procedure
        when_i_incomplete_the_procedure
        when_i_view_the_notes_list
        then_i_should_see_two_incomplete_notes_and_one_complete_note
      end
    end

    context 'and marks a procedure as incomplete and then changes their mind, clicking unstarted' do
      scenario 'and sees the status reset note, and status and performed by have been reset' do
        given_i_am_viewing_an_appointment_with_a_procedure
        when_i_begin_the_appointment
        when_i_incomplete_the_procedure
        when_i_unstart_the_procedure
        when_i_view_the_notes_list
        then_i_should_see_one_status_incomplete_note
        then_i_should_see_that_the_procedure_status_has_been_reset
        then_i_should_see_that_the_procedure_performed_by_has_been_reset
      end
    end
  end

  context 'User does not start an appointment' do
    context 'and attempts to mark a procedure as incomplete' do
      scenario 'and sees an error message' do
        given_i_am_viewing_an_appointment_with_a_procedure
        when_i_try_to_incomplete_the_procedure
        then_i_should_see_a_helpful_message
      end
    end
  end

  def given_i_am_viewing_an_appointment_with_a_procedure
    protocol    = create_and_assign_protocol_to_me
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

  def given_i_am_viewing_a_procedure_marked_as_complete
    given_i_am_viewing_an_appointment_with_a_procedure
    when_i_begin_the_appointment
    find("div#procedure#{@procedure.id}StatusButtons button.complete-btn").click
    wait_for_ajax
  end

  def when_i_begin_the_appointment
    find('a.start-appointment').click
    wait_for_ajax
  end

  def when_i_complete_the_procedure
    find("div#procedure#{@procedure.id}StatusButtons button.complete-btn").click
    wait_for_ajax
  end

  def when_i_incomplete_the_procedure
    when_i_click_the_incomplete_button
    when_i_provide_a_reason
    when_i_save_the_incomplete
  end

  def when_i_unstart_the_procedure
    find("div#procedure#{@procedure.id}StatusButtons button.unstarted-btn").click
    wait_for_ajax
  end

  def when_i_click_the_incomplete_button
    find("div#procedure#{@procedure.id}StatusButtons button.incomplete-btn").click
    wait_for_ajax
  end

  def when_i_provide_a_reason
    reason = Procedure::NOTABLE_REASONS.first
    bootstrap_select '#procedure_notes_attributes_0_reason', reason
    fill_in 'Comment', with: 'Test comment'
  end

  def when_i_save_the_incomplete
    sleep 1
    find('input[type="submit"]').click
    wait_for_ajax
  end

  def when_i_cancel_the_incomplete
    sleep 1
    find("button.btn-secondary").click
    wait_for_ajax
  end

  def then_i_should_see_that_i_am_the_procedure_performer
    expect(page).to have_css("td.performer button.btn[title='#{@logged_in_identity.first_name} #{@logged_in_identity.last_name}']")
  end

  def when_i_view_the_notes_list
    find("div#procedure#{@procedure.id}Notes a.btn").click
  end

  def when_i_close_the_notes_list
    first(".modal button.close").click
  end

  def when_i_try_to_incomplete_the_procedure
    find("div#procedure#{@procedure.id}StatusButtons button.incomplete-btn").click
    wait_for_ajax
  end

  def then_i_should_see_one_complete_note
    expect(page).to have_css('.note-body p', text: 'Status set to complete', count: 1)
  end

  def then_i_should_see_one_incomplete_note
    expect(page).to have_css('.note-body p', text: 'Status set to incomplete', count: 1)
  end

  def then_i_should_see_errors
    sleep 1
    expect(page).to have_css('small.form-text.form-error', text: "Can't be blank")
  end
  
  def then_i_should_see_one_complete_note_and_one_incomplete_note
    then_i_should_see_one_complete_note
    then_i_should_see_one_incomplete_note
  end

  def then_i_should_see_two_incomplete_notes_and_one_complete_note
    expect(page).to have_css('.note-body p', text: 'Status set to incomplete', count: 2)
  end

  def then_i_should_see_one_status_incomplete_note
    expect(page).to have_css('.note-body p', text: 'Status set to incomplete', count: 1)
  end

  def then_i_should_see_that_the_procedure_status_has_been_reset
    expect(page).to have_css("div#procedure#{@procedure.id}StatusButtons .unstarted-btn.active")
  end

  def then_i_should_see_that_the_procedure_performed_by_has_been_reset
    expect(page).to_not have_css("td.performer button.btn[title='#{@logged_in_identity.first_name} #{@logged_in_identity.last_name}']")
  end

  def then_i_should_see_a_helpful_message
    expect(page).to have_css("div#procedure#{@procedure.id}StatusButtons[data-original-title=\"Click \'Start Visit\' and enter a start date to continue.\"]", visible: false)
  end
end
