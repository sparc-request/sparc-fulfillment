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

RSpec.describe 'Incomplete Procedure', type: :system, js: true do
  let!(:protocol)              { create_and_assign_protocol_to_me }
  let!(:protocols_participant) { protocol.protocols_participants.first }
  let!(:service)               { protocol.organization.inclusive_child_services(:per_participant).first }

  # Lazily evaluated: safely queries the DB for the newly created procedure only when needed
  let(:procedure)              { protocols_participant.appointments.first.procedures.find_by(service: service) }

  context 'User starts an appointment' do
    context 'and marks a procedure as incomplete once' do
      scenario 'and sees a single incomplete note' do
        given_i_am_viewing_a_started_visit(participant: protocols_participant, protocol: protocol)
        and_i_have_added_a_procedure
        when_i_incomplete_the_procedure
        when_i_view_the_notes_list
        then_i_should_see_one_incomplete_note
      end
    end

    context 'and attempts to mark a procedure as incomplete without selecting a reason' do
      scenario 'and sees some errors' do
        given_i_am_viewing_a_started_visit(participant: protocols_participant, protocol: protocol)
        and_i_have_added_a_procedure
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
    end

    context 'and marks an unstarted procedure as incomplete and then cancels' do
      scenario 'and sees that the procedure status is the same' do
        given_i_am_viewing_a_started_visit(participant: protocols_participant, protocol: protocol)
        and_i_have_added_a_procedure
        when_i_click_the_incomplete_button
        when_i_cancel_the_incomplete
        then_i_should_see_that_the_procedure_status_has_been_reset
      end
    end

    context 'and marks a procedure as incomplete, then complete, then incomplete again' do
      scenario 'and sees two incomplete notes' do
        given_i_am_viewing_a_started_visit(participant: protocols_participant, protocol: protocol)
        and_i_have_added_a_procedure
        when_i_incomplete_the_procedure
        when_i_complete_the_procedure
        when_i_incomplete_the_procedure
        when_i_view_the_notes_list
        then_i_should_see_two_incomplete_notes_and_one_complete_note
      end
    end

    context 'and marks a procedure as incomplete and then changes their mind, clicking unstarted' do
      scenario 'and sees the status reset note, and status and performed by have been reset' do
        given_i_am_viewing_a_started_visit(participant: protocols_participant, protocol: protocol)
        and_i_have_added_a_procedure
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
        given_i_am_viewing_a_visit(participant: protocols_participant, protocol: protocol)
        and_i_have_added_a_procedure
        when_i_try_to_incomplete_the_procedure
        then_i_should_see_a_helpful_message
      end
    end
  end

  def and_i_have_added_a_procedure
    add_a_procedure(service: service)
  end

  def given_i_am_viewing_a_procedure_marked_as_complete
    given_i_am_viewing_a_started_visit(participant: protocols_participant, protocol: protocol)
    and_i_have_added_a_procedure
    when_i_complete_the_procedure
  end

  def when_i_complete_the_procedure
    within("#procedure#{procedure.id}StatusButtons") do
      find('button.complete-btn').click
    end
    expect(page).to have_css("#procedure#{procedure.id}StatusButtons button.complete-btn.active")
  end

  def when_i_incomplete_the_procedure
    when_i_click_the_incomplete_button
    when_i_provide_a_reason
    when_i_save_the_incomplete
    
    # Native sync point to ensure the modal disappears and the UI updates successfully
    expect(page).to have_no_css('.modal.show')
    expect(page).to have_css("#procedure#{procedure.id}StatusButtons button.incomplete-btn.active")
  end

  def when_i_unstart_the_procedure
    within("#procedure#{procedure.id}StatusButtons") do
      find('button.unstarted-btn').click
    end
    expect(page).to have_css("#procedure#{procedure.id}StatusButtons button.unstarted-btn.active")
  end

  def when_i_click_the_incomplete_button
    within("#procedure#{procedure.id}StatusButtons") do
      find('button.incomplete-btn').click
    end
    # Native wait for the modal to render
    expect(page).to have_css('.modal.show')
  end

  def when_i_provide_a_reason
    within('.modal.show') do
      # Dynamically grab the first available reason to avoid hardcoding arrays
      find('#procedure_notes_attributes_0_reason', visible: :hidden).ancestor('.bootstrap-select', match: :first).find('.dropdown-toggle').click
      expect(page).to have_css('.dropdown-menu.show')
      find('.dropdown-menu.show span.text', match: :first).click

      fill_in 'Comment', with: 'Test comment'
    end
  end

  def when_i_save_the_incomplete
    within('.modal.show') do
      find('input[type="submit"]').click
    end
  end

  def when_i_cancel_the_incomplete
    within('.modal.show') do
      find('button.btn-secondary').click
    end
    
    # Retry loop: if Bootstrap animation swallowed the immediate click, natively retry
    retries = 3
    begin
      expect(page).to have_no_css('.modal.show', wait: 2)
    rescue RSpec::Expectations::ExpectationNotMetError
      retries -= 1
      if retries > 0
        find('.modal.show button.btn-secondary').click if page.has_css?('.modal.show button.btn-secondary')
        retry
      else
        raise
      end
    end
  end

  def when_i_view_the_notes_list
    # Removed the ambiguous comma selector and strictly target the clickable button
    find("div#procedure#{procedure.id}Notes a.btn").click
    expect(page).to have_css('.modal.show')
  end

  def when_i_close_the_notes_list
    within('.modal.show') do
      find('button.close').click
    end
    expect(page).to have_no_css('.modal.show')
  end

  def when_i_try_to_incomplete_the_procedure
    within("#procedure#{procedure.id}StatusButtons") do
      find('button.incomplete-btn').click
    end
  end

  def then_i_should_see_one_complete_note
    within('.modal.show') do
      expect(page).to have_css('.note-body p', text: 'Status set to complete', count: 1)
    end
  end

  def then_i_should_see_one_incomplete_note
    within('.modal.show') do
      expect(page).to have_css('.note-body p', text: 'Status set to incomplete', count: 1)
    end
  end

  def then_i_should_see_errors
    # Retry loop: if Bootstrap animation swallowed the immediate submit click, natively retry
    retries = 3
    begin
      within('.modal.show') do
        expect(page).to have_css('small.form-text.form-error', text: "Can't be blank", wait: 2)
      end
    rescue RSpec::Expectations::ExpectationNotMetError
      retries -= 1
      if retries > 0
        within('.modal.show') { find('input[type="submit"]').click }
        retry
      else
        raise
      end
    end
  end
  
  def then_i_should_see_one_complete_note_and_one_incomplete_note
    then_i_should_see_one_complete_note
    then_i_should_see_one_incomplete_note
  end

  def then_i_should_see_two_incomplete_notes_and_one_complete_note
    within('.modal.show') do
      expect(page).to have_css('.note-body p', text: 'Status set to incomplete', count: 2)
      expect(page).to have_css('.note-body p', text: 'Status set to complete', count: 1)
    end
  end

  def then_i_should_see_one_status_incomplete_note
    within('.modal.show') do
      expect(page).to have_css('.note-body p', text: 'Status set to incomplete', count: 1)
    end
  end

  def then_i_should_see_that_the_procedure_status_has_been_reset
    expect(page).to have_css("div#procedure#{procedure.id}StatusButtons .unstarted-btn.active")
  end

  def then_i_should_see_that_the_procedure_performed_by_has_been_reset
    # Bootstrap natively sets the title to "Nothing selected" when the dropdown is cleared
    expect(page).to have_css("td.performer button.btn[title='Nothing selected']")
  end

  def then_i_should_see_a_helpful_message
    expect(page).to have_css("div#procedure#{procedure.id}StatusButtons[data-original-title=\"Click 'Start Visit' and enter a start date to continue.\"]", visible: :all)
  end
end
