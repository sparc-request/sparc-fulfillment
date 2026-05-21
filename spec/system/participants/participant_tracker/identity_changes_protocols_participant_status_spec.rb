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

feature 'User changes the status of a participant on the participant tracker', js: true do

  scenario 'and sees the updated status on the page' do
    given_i_am_viewing_the_participant_tracker
    when_i_update_the_participant_status
    then_i_should_see_the_updated_status
  end

  scenario 'and sees the status updated note' do
    given_i_am_viewing_the_participant_tracker
    when_i_update_the_participant_status
    then_i_should_see_an_associated_note
  end

  def given_i_am_viewing_the_participant_tracker
    @protocol    = create_and_assign_protocol_to_me
    @protocols_participant = @protocol.protocols_participants.last

    visit protocol_path(@protocol.id)

    expect(page).to have_link('Participant Tracker', visible: true, wait: 5)
    click_link 'Participant Tracker'

    expect(page).to have_css("select[id*='protocols_participant_status']", visible: :all, wait: 15)
  end

  def when_i_update_the_participant_status
    hidden_select = find("select[id*='protocols_participant_status']", visible: :all, match: :first)
    
    target_option = hidden_select.find('option', text: 'Screening', visible: :all)
    
    page.execute_script("$(arguments[0]).val(arguments[1]).trigger('change');", hidden_select, target_option.value)

    visit protocol_path(@protocol.id)

    expect(page).to have_link('Participant Tracker', visible: true, wait: 5)
    click_link 'Participant Tracker'

    expect(page).to have_css("select[id*='protocols_participant_status']", visible: :all, wait: 15)
  end

  def then_i_should_see_the_updated_status
    expect(page).to have_css('#participantTrackerTable tbody tr:first-child', text: 'Screening', wait: 10)
  end

  def then_i_should_see_an_associated_note
    expect(page).to have_css('#participantTrackerTable tbody tr:first-child', text: 'Screening', wait: 10)
    
    find("#participant#{@protocols_participant.id}Notes a", wait: 10).click

    expect(page).to have_content('Status changed', wait: 10)
  end
end
