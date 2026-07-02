# Copyright © 2011-2023 MUSC Foundation for Research Development
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

RSpec.describe 'User associates Participant to Protocol', type: :system, js: true do
  let!(:protocol)          { create_and_assign_protocol_to_me }
  let!(:participant)       { create(:participant) }
  let!(:patient_registrar) { create(:patient_registrar, identity: Identity.first, organization: create(:organization)) }

  scenario 'and sees the new Participants in the list' do
    given_i_am_viewing_the_associate_participants_to_protocol_modal
    then_i_should_see_associated_participants
    when_i_click_to_associate_a_participant
    then_i_should_see_the_new_participant_in_the_list
  end

  def given_i_am_viewing_the_associate_participants_to_protocol_modal
    visit protocol_path(protocol.id)
    
    # Sync point: wait for the default page state to fully render
    expect(page).to have_css('a.active#studyScheduleTabLink')

    # Bootstrap animations can swallow clicks if fired during a fade transition - safely poll and click until the underlying toolbar physically renders
    while page.has_no_css?('#participantTrackerToolbar', visible: true, wait: 0.5)
      click_link 'Participant Tracker'
    end

    # Bypassing the FontAwesome icon squashing with a regex and direct CSS targeting
    expect(page).to have_css('a.btn-success', text: /Search Patient Registry/i)
    find('a.btn-success', text: /Search Patient Registry/i).click

    expect(page).to have_css('.modal-dialog')
  end

  def then_i_should_see_associated_participants
    within('.modal-dialog') do
      expect(page).to have_css('.associate a.remove-participant', count: protocol.protocols_participants.count)
    end
  end

  def when_i_click_to_associate_a_participant
    within('.modal-dialog') do
      find('.associate a.add-participant', match: :first).click
    end
  end

  def then_i_should_see_the_new_participant_in_the_list
    expect(page).to have_css('#flashContainer', text: /Participant was updated successfully/i)
    
    within('.modal-dialog') do
      click_button 'Close'
    end

    expect(page).to have_no_css('.modal-dialog')
    expect(page).to have_css('#participantTrackerTable tbody tr', count: 4)
  end
  
  alias_method :i_should_see_associated_participants, :then_i_should_see_associated_participants
end