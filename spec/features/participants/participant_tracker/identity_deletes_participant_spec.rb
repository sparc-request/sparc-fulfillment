# Copyright © 2011-2017 MUSC Foundation for Research Development~
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

feature 'User deletes Participant', js: true do

  scenario 'and sees the Participant is removed from the list' do
    given_i_have_a_participant
    given_i_am_viewing_the_participant_tracker
    when_i_delete_a_participant
    then_i_should_not_see_the_participant
  end

  scenario 'and connot delete when there is procedure data' do
    given_i_have_a_participant
    and_the_participant_is_not_deletable
    given_i_am_viewing_the_participant_tracker
    then_i_should_see_disabled_delete_button
  end

  def and_the_participant_is_not_deletable
    participant = Participant.first
    create(:procedure_complete, appointment: participant.appointments.first, arm: @protocol.arms.first)
  end

  def given_i_have_a_participant
    @protocol = create_and_assign_protocol_to_me
  end

  def given_i_am_viewing_the_participant_tracker
    visit protocol_path(@protocol.id)
    wait_for_ajax

    click_link 'Participant Tracker'
    wait_for_ajax
  end

  def when_i_delete_a_participant
    accept_confirm do
      page.find('table.participants tbody tr:first-child td.delete a').click
    end

    refresh_bootstrap_table 'table.participants'
  end

  def then_i_should_not_see_the_participant
    expect(page).to have_css('#flashes_container', text: 'Participant Removed')
    expect(page).to have_css('table.participants tbody tr', count: 2)
  end

  def then_i_should_see_disabled_delete_button
    expect(page).to have_css('div[data-original-title="Participants with procedure data cannot be deleted."]')
  end
end
