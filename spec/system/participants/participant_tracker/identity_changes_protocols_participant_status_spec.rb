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

RSpec.describe 'User changes the status of a participant on the participant tracker', type: :system, js: true do
  let!(:protocol) { create_and_assign_protocol_to_me }
  let!(:protocols_participant) { protocol.protocols_participants.last }

  context 'when updating a participant status' do
    scenario 'sees the updated status on the page' do
      given_i_am_viewing_the_participant_tracker
      when_i_update_the_participant_status
      then_i_should_see_the_updated_status
    end

    scenario 'sees the status updated note' do
      given_i_am_viewing_the_participant_tracker
      when_i_update_the_participant_status
      then_i_should_see_an_associated_note
    end
  end

  def given_i_am_viewing_the_participant_tracker
    visit protocol_path(protocol.id)
    
    expect(page).to have_content('Manage Arms')
    
    click_link 'Participant Tracker'
    
    expect(page).to have_css('#participantTrackerTable', visible: :all)
  end

  def when_i_update_the_participant_status
    bootstrap_select(
      '#protocols_participant_status', 
      'Screening', 
      context_selector: '#participantTrackerTable tbody tr:first-child'
    )
  end

  def then_i_should_see_the_updated_status
    within('#participantTrackerTable tbody tr:first-child') do
      expect(bootstrap_selected?('protocols_participant_status', 'Screening')).to be
    end
  end

  def then_i_should_see_an_associated_note
    within('#participantTrackerTable tbody tr:first-child') do
      expect(bootstrap_selected?('protocols_participant_status', 'Screening')).to be
      
      find("#participant#{protocols_participant.id}Notes a").click
    end

    expect(page).to have_content('Status changed')
  end
end
