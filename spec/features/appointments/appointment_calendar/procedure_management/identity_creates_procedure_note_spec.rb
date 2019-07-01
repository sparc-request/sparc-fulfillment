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

feature 'User creates a procedure note', js: true do

  context 'and views the Notes list before create' do
    scenario 'and sees a notification that there are no notes' do
      given_i_have_added_a_procedure_to_the_appointment_calendar
      when_i_begin_an_appointment
      when_i_view_the_notes_list
      then_i_should_see_a_notice_that_there_are_no_notes
    end
  end

  scenario 'and sees the note in the notes list' do
    given_i_have_added_a_procedure_to_the_appointment_calendar
    when_i_begin_an_appointment
    when_i_add_a_note_to_the_procedure
    then_i_should_see_the_note
  end

  def given_i_have_added_a_procedure_to_the_appointment_calendar
    protocol    = create_and_assign_protocol_to_me
    protocols_participant = protocol.protocols_participants.first
    visit_group = protocols_participant.appointments.first.visit_group
    service     = protocol.organization.inclusive_child_services(:per_participant).first

    visit calendar_participants_path(participant_id: protocols_participant.participant_id, protocols_participant_id: protocols_participant.id, protocol_id: protocol.id)
    wait_for_ajax

    bootstrap_select '#appointment_select', visit_group.name
    wait_for_ajax

    bootstrap_select '#service_list', service.name
    fill_in 'service_quantity', with: '1'
    find('button.add_service').click
    wait_for_ajax
  end

  def when_i_begin_an_appointment
    find('button.start_visit').click
    wait_for_ajax
  end

  def when_i_add_a_note_to_the_procedure
    find('.procedure td.notes button.notes.list').click
    find('button.note.new').click
    fill_in 'note_comment', with: 'Test comment'
    click_button 'Save'
  end

  def when_i_view_the_notes_list
    find('.procedure td.notes button.notes.list').click
  end

  def then_i_should_see_a_notice_that_there_are_no_notes
    expect(page).to have_css('.modal-body', text: 'This Procedure currently has no notes')
  end

  def then_i_should_see_the_note
    expect(page).to have_css('.modal-body .detail .comment', text: 'Test comment')
  end
end
