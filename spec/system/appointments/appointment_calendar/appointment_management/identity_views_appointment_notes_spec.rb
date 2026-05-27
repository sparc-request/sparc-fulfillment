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

RSpec.describe 'User creates an appointment note', type: :system, js: true do
  
  let!(:protocol) { create_and_assign_protocol_to_me(identity: @logged_in_identity) }
  let!(:protocols_participant) { protocol.protocols_participants.first }
  let!(:visit_group) { protocols_participant.appointments.first.visit_group }

  context 'and views the Notes List before create' do
    scenario 'and sees the automatically generated audit notes' do
      given_i_am_viewing_an_appointment
      when_i_view_the_notes_list
      then_i_should_see_current_notes
    end
  end

  scenario 'and sees a newly created note' do
    given_i_am_viewing_an_appointment
    when_i_create_a_note
    then_i_should_see_the_created_note
  end

  def given_i_am_viewing_an_appointment
    visit calendar_protocol_participant_path(id: protocols_participant.id, protocol_id: protocol.id)

    # Use match: :first to dodge duplicate sidebar elements safely
    find('a.list-group-item.appointment-link', text: visit_group.name, match: :first).click

    within('#appointmentContainer') do
      expect(page).to have_css('h3', text: /#{visit_group.name}/i)
    end
  end

  def when_i_view_the_notes_list
    within("div#participant#{protocols_participant.id}Notes") do
      find('a.btn').click
    end
    
    # Force Capybara to wait for Bootstrap to finish fading the modal in
    expect(page).to have_css('.modal-dialog', visible: true)
    expect(page).to have_css('.note-body', visible: true)
  end

  def when_i_create_a_note
    when_i_view_the_notes_list
    
    # Blind Capybara to the rest of the massive DOM so it can't click the wrong button
    within('.modal-content') do
      expect(page).to have_field('note_comment')
      fill_in 'note_comment', with: "I'm a note. Fear me."
      
      find('.modal-header').click
      
      click_button 'Leave Note'
    end
    
    expect(page).to have_css('div.note-body p', text: "I'm a note. Fear me.")
  end

  def then_i_should_see_current_notes
    within('.modal-content') do
      # Capybara will natively poll until these elements appear or timeout
      expect(page).to have_css('div.note-body p', text: /Status changed from N\/A/i)
      expect(page).to have_css('div.note-body p', text: /Current Arm changed from N\/A/i)
    end
  end

  def then_i_should_see_the_created_note
    within('.modal-content') do
      # Validate exact input rendered to the DOM natively
      expect(page).to have_css('div.note-body p', text: "I'm a note. Fear me.")
    end
  end
end
