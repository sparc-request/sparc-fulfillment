# Copyright © 2011-2018 MUSC Foundation for Research Development~
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

feature 'User associates Participant to Protocol', js: true do

  scenario 'and sees the new Participants in the list' do
    given_i_am_viewing_the_associate_participants_to_protocol_modal
    i_should_see_associated_participants_as_checked
    when_i_click_to_associate_a_participant
    then_i_should_see_the_new_participant_in_the_list
  end

  def given_i_am_viewing_the_associate_participants_to_protocol_modal
    @protocol    = create_and_assign_protocol_to_me
    create(:participant)
    visit protocol_path(@protocol.id)
    wait_for_ajax

    click_link 'Participant Tracker'
    wait_for_ajax

    click_button 'Search For Participants'
    wait_for_ajax
  end

  def i_should_see_associated_participants_as_checked
    expect(all('input[type=checkbox]:checked').count).to eq(@protocol.protocols_participants.count)
  end

  def when_i_click_to_associate_a_participant
    all_participant_ids = Participant.all.map(&:id)
    participant_ids_associated_to_protocol = @protocol.protocols_participants.map(&:id)
    participant_id_left_to_associate = (all_participant_ids + participant_ids_associated_to_protocol) - (all_participant_ids & participant_ids_associated_to_protocol)
    find("input[type='checkbox'][participant_id='#{participant_id_left_to_associate.first}']").set(true)
    wait_for_ajax
  end

  def then_i_should_see_the_new_participant_in_the_list
    expect(page).to have_css('#flashes_container', text: 'Participant added to protocol.')
    wait_for_ajax
    click_button 'Close'
    wait_for_ajax
    expect(page).to have_css('table.participants tbody tr', count: 4)
  end
end