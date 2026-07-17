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

RSpec.describe 'User deletes Participant', type: :system, js: true do
  let(:protocol)              { create_and_assign_protocol_to_me }
  let(:protocols_participant) { protocol.protocols_participants.last }

  context 'when a participant has no procedure data' do
    scenario 'sees the Participant is removed from the list' do
      given_i_am_viewing_the_participant_tracker
      when_i_delete_a_participant
      then_i_should_not_see_the_participant
    end
  end

  context 'when a participant has procedure data' do
    let!(:procedure) do
      create(:procedure_complete, appointment: protocols_participant.appointments.first, arm: protocol.arms.first)
    end

    scenario 'cannot delete the participant and sees disabled button' do
      given_i_am_viewing_the_participant_tracker
      then_i_should_see_disabled_delete_button
    end
  end

  def given_i_am_viewing_the_participant_tracker
    visit protocol_path(protocol.id)
    
    expect(page).to have_content('Manage Arms')
    
    click_link 'Participant Tracker'
    expect(page).to have_css('#participantTrackerTable', visible: :all)
  end

  def when_i_delete_a_participant
    within('#participantTrackerTable tbody tr:first-child') do
      find('.remove-participant').click
    end

    expect(page).to have_css('.swal2-container', visible: true)

    find('button.swal2-confirm').click

    expect(page).to have_no_css('.swal2-container', visible: true)
  end

  def then_i_should_not_see_the_participant
    expect(page).to have_css('#participantTrackerTable tbody tr', count: 2)
  end

  def then_i_should_see_disabled_delete_button
    expect(page).to have_css('div[data-original-title="Participants with procedure data cannot be deleted"]')
  end
end
