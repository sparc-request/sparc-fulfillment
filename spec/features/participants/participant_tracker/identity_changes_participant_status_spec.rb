# Copyright © 2011-2016 MUSC Foundation for Research Development~
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
    @participant = @protocol.participants.first

    visit protocol_path @protocol.id
    wait_for_ajax

    click_link 'Participant Tracker'
    wait_for_ajax
  end

  def when_i_update_the_participant_status
    bootstrap_select "#participant_status_#{@participant.id}", "Screening"
    wait_for_ajax

    refresh_bootstrap_table 'table.participants'
    wait_for_ajax
  end

  def then_i_should_see_the_updated_status
    expect(bootstrap_selected?("participant_status_#{@participant.id}", "Screening")).to be
  end

  def then_i_should_see_an_associated_note
    expect(bootstrap_selected?("participant_status_#{@participant.id}", "Screening")).to be
    wait_for_ajax
    find("button.participant_notes[data-notable-id='#{@participant.id}']").click
    wait_for_ajax

    expect(page).to have_content('Status changed')
  end
end
