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

feature 'User associates Participant to Protocol', js: true do

  scenario 'and sees the new Participants in the list' do
    given_i_am_viewing_the_associate_participants_to_protocol_modal
    i_should_see_associated_participants
    when_i_click_to_associate_a_participant
    then_i_should_see_the_new_participant_in_the_list
  end

  def given_i_am_viewing_the_associate_participants_to_protocol_modal
    @protocol    = create_and_assign_protocol_to_me
    create(:participant)
    create(:patient_registrar, identity: Identity.first, organization: create(:organization))

    visit protocol_path(@protocol.id)
    
    expect(page).to have_link('Participant Tracker', visible: true, wait: 5)
    click_link 'Participant Tracker'

    expect(page).to have_link('Search Patient Registry', visible: true, wait: 5)
    click_link 'Search Patient Registry'

    expect(page).to have_css('.modal', visible: true, wait: 5)
  end

  def i_should_see_associated_participants
    expected_count = @protocol.protocols_participants.count
    expect(page).to have_css('.associate a.remove-participant', count: expected_count, wait: 5)
  end

  def when_i_click_to_associate_a_participant
    @initial_remove_count = all('.associate a.remove-participant').count
    
    first('.associate a.add-participant').click
    
    expect(page).to have_css('.associate a.remove-participant', count: @initial_remove_count + 1, wait: 10)
  end

  def then_i_should_see_the_new_participant_in_the_list
    expect(page).to have_css('#flashContainer', text: 'Participant was updated successfully!', wait: 5)
    
    within('.modal') do
      find('button', text: 'Close', exact_text: true, visible: :all).click
    end

    expect(page).to have_no_css('.modal', wait: 10)
    expect(page).to have_no_css('.modal-backdrop', wait: 10)

    visit protocol_path(@protocol.id)
    
    expect(page).to have_link('Participant Tracker', visible: true, wait: 5)
    click_link 'Participant Tracker'

    expect(page).to have_css('#participantTrackerTable tbody tr', count: 4, wait: 10)
  end
end
