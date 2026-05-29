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

RSpec.describe 'Identity completes Procedure', type: :system, js: true do
  let!(:protocol)              { create_and_assign_protocol_to_me }
  let!(:protocols_participant) { protocol.protocols_participants.first }
  let!(:service)               { protocol.organization.inclusive_child_services(:per_participant).first }

  # Lazily evaluated: safely queries the DB for the newly created procedure only when needed
  let(:procedure)              { protocols_participant.appointments.first.procedures.find_by(service: service) }

  scenario 'and sees a completed Note' do
    given_i_am_viewing_a_started_visit(participant: protocols_participant, protocol: protocol)
    and_i_have_added_a_procedure
    when_i_complete_the_procedure
    when_i_view_the_notes_list
    then_i_should_see_complete_notes
  end

  context 'and changes their mind, clicking the unstarted button' do
    scenario 'and sees the reset note' do
      given_i_am_viewing_a_started_visit(participant: protocols_participant, protocol: protocol)
      and_i_have_added_a_procedure
      when_i_complete_the_procedure
      and_i_reset_the_procedure
      when_i_view_the_notes_list
      then_i_should_see_reset_notes
    end
  end

  context 'which was previously incomplete' do
    scenario 'and sees the complete note' do
      given_i_am_viewing_a_started_visit(participant: protocols_participant, protocol: protocol)
      and_i_have_added_a_procedure
      when_i_incomplete_the_procedure
      when_i_complete_the_procedure
      when_i_view_the_notes_list
      then_i_should_see_complete_notes
    end
  end

  context 'before starting Appointment' do
    scenario 'and sees a helpful error message' do
      given_i_am_viewing_a_visit(participant: protocols_participant, protocol: protocol)
      and_i_have_added_a_procedure
      then_i_should_see_a_helpful_message
    end
  end

  def and_i_have_added_a_procedure
    add_a_procedure(service: service)
  end

  def when_i_complete_the_procedure
    # Strict scoping to the specific procedure's button group
    within("#procedure#{procedure.id}StatusButtons") do
      find('button.complete-btn').click
    end
    expect(page).to have_css("#procedure#{procedure.id}StatusButtons button.complete-btn.active")
  end

  def and_i_reset_the_procedure
    # Click the dedicated unstarted button natively
    within("#procedure#{procedure.id}StatusButtons") do
      find('button.unstarted-btn').click
    end
    
    # Sync point: wait for the complete button to natively lose its active state
    expect(page).to have_no_css("#procedure#{procedure.id}StatusButtons button.complete-btn.active")
  end

  def when_i_incomplete_the_procedure
    within("#procedure#{procedure.id}StatusButtons") do
      find('button.incomplete-btn').click
    end
    
    # Native wait for the modal to render
    expect(page).to have_css('.modal.show')
    
    within('.modal.show') do
      bootstrap_select '#procedure_notes_attributes_0_reason', "Assessment missed"
      find('input[type="submit"]').click
    end
    
    # Sync point: natively wait for the modal to vanish
    expect(page).to have_no_css('.modal.show')
    expect(page).to have_css("#procedure#{procedure.id}StatusButtons button.incomplete-btn.active")
  end

  def when_i_view_the_notes_list
    find("div#procedure#{procedure.id}Notes").click
    expect(page).to have_css('.modal.show')
  end

  def then_i_should_see_complete_notes
    within('.modal.show') do
      expect(page).to have_css('div.note-body', text: 'Status set to complete')
    end
  end

  def then_i_should_see_reset_notes
    within('.modal.show') do
      expect(page).to have_css('div.note-body', text: 'Status reset')
    end
  end

  def then_i_should_see_a_helpful_message
    expect(page).to have_css("div#procedure#{procedure.id}StatusButtons[data-original-title=\"Click 'Start Visit' and enter a start date to continue.\"]", visible: :all)
  end
end