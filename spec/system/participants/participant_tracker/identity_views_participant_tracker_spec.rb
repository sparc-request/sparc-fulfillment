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

feature 'User views Participant Tracker', js: true do

  scenario 'and sees Participants' do
    given_i_have_a_protocol_with_a_participant
    when_i_view_the_participant_tracker
    then_i_should_see_the_participant_in_the_table
  end

  def given_i_have_a_protocol_with_a_participant
    @protocol = create_and_assign_protocol_to_me
    
    keep_id = @protocol.protocols_participants.first.id
    @protocol.protocols_participants.where.not(id: keep_id).destroy_all
    
    @protocols_participant = @protocol.protocols_participants.first
    
    expect(@protocols_participant).to be_present
  end

  def when_i_view_the_participant_tracker
    visit protocol_path(@protocol.id)

    expect(page).to have_link('Participant Tracker', visible: true, wait: 5)
    click_link 'Participant Tracker'

    expect(page).to have_css('#participantTrackerTable tbody tr', visible: true, wait: 15)
  end

  def then_i_should_see_the_participant_in_the_table
    participant = @protocols_participant.participant

    table_selector = '#participantTrackerTable'
    
    expect(page).to have_css(table_selector, text: participant.first_name, wait: 10)
    expect(page).to have_css(table_selector, text: participant.last_name, wait: 10)
  end
end
