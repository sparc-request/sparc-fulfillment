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

RSpec.describe 'Identity creates a procedure note', type: :system, js: true do
  let(:protocol)              { create_and_assign_protocol_to_me }
  let(:protocols_participant) { protocol.protocols_participants.first }
  let(:service)               { protocol.organization.inclusive_child_services(:per_participant).first }

  # Lazily evaluated: safely queries the DB for the newly created procedure only when needed
  let(:procedure)              { protocols_participant.appointments.first.procedures.find_by(service: service) }
  
  # Extracted to prevent time-travel test flakiness
  let(:target_date)            { Date.current.change(day: 10) }

  context 'and views the Notes list before create' do
    scenario 'and sees a notification that there are no notes' do
      given_i_am_viewing_a_started_visit(participant: protocols_participant, protocol: protocol)
      and_i_have_added_a_procedure
      when_i_view_the_notes_list
      then_i_should_see_a_notice_that_there_are_no_notes
    end
  end

  scenario 'and sees the note in the notes list' do
    given_i_am_viewing_a_started_visit(participant: protocols_participant, protocol: protocol)
    and_i_have_added_a_procedure
    when_i_set_a_followup
    when_i_view_the_notes_list
    then_i_should_see_the_note
  end

  def and_i_have_added_a_procedure
    add_a_procedure(service: service)
  end

  def when_i_set_a_followup
    find("div#followup#{procedure.id} a.btn").click
    
    # Native wait for the modal to ensure it's fully rendered before filling
    expect(page).to have_css('.modal.show')

    # Bypassing the brittle 'Identity.first' DB query by natively grabbing the first available dropdown option
    find('#task_assignee_id', visible: :hidden).ancestor('.bootstrap-select', match: :first).find('.dropdown-toggle').click
    expect(page).to have_css('.dropdown-menu.show')
    find('.dropdown-menu.show span.text', match: :first).click

    # Explicitly pass the formatted text string since the input is writable
    bootstrap_datepicker '#task_due_at', text: target_date.strftime('%m/%d/%Y')
    fill_in 'Comment', with: 'Test comment'
    
    # Safely strict-scope just the submit button
    within('.modal.show') do
      find('input[type="submit"]').click
    end
    
    # Sync point: natively wait for the modal to vanish, eliminating wait_for_ajax
    expect(page).to have_no_css('.modal.show')
  end

  def when_i_view_the_notes_list
    find("div#procedure#{procedure.id}Notes a.btn").click
    # Native wait for the notes modal to render
    expect(page).to have_css('.modal.show')
  end

  def then_i_should_see_a_notice_that_there_are_no_notes
    within('.modal.show') do
      expect(page).to have_css('div.alert', text: "This Procedure doesn't have any notes.")
    end
  end

  def then_i_should_see_the_note
    within('.modal.show') do
      expect(page).to have_css('.note-body p', text: "Followup: #{target_date.strftime('%Y-%m-%d')}: Test comment")
    end
  end
end
