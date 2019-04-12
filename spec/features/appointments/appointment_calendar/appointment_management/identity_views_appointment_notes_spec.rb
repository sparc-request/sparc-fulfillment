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

feature 'User creates an appointment note', js: true do

  context 'and views the Notes List before create' do
    scenario 'and sees a notification that there are no notes' do
      given_i_am_viewing_an_appointment
      when_i_view_the_notes_list
      then_i_should_see_a_notice_that_there_are_no_notes
    end
  end

  scenario 'and sees a note' do
    given_i_am_viewing_an_appointment
    when_i_create_a_note
    then_i_should_see_the_note
  end

  def given_i_am_viewing_an_appointment
    protocol      = create_and_assign_protocol_to_me
    @protocols_participant  = protocol.protocols_participants.first
    @visit_group  = @protocols_participant.appointments.first.visit_group
    @identity     = create(:identity)

    visit calendar_participants_path(participant_id: @protocols_participant.participant_id, protocols_participant_id: @protocols_participant.id, protocol_id: protocol.id)
    wait_for_ajax

    bootstrap_select '#appointment_select', @visit_group.name
    wait_for_ajax
  end

  def when_i_view_the_notes_list
    find('h3.appointment_header button.notes.list').click
    wait_for_ajax
  end

  def when_i_create_a_note
    when_i_view_the_notes_list
    wait_for_ajax
    click_button 'Add Note'
    wait_for_ajax
    fill_in 'note_comment', with: "I'm a note. Fear me."
    click_button 'Save'
    wait_for_ajax
  end

  def then_i_should_see_a_notice_that_there_are_no_notes
    expect(page).to have_css('.modal-body', text: 'This Appointment currently has no notes')
  end

  def then_i_should_see_the_note
    expect(page).to have_css('.modal-body', text: "I'm a note. Fear me.")
  end
end
