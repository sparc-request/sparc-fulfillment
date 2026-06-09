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

RSpec.describe 'User views the participant tracker page', type: :system, js: true do
  let!(:protocol)              { create_and_assign_protocol_to_me }
  let!(:protocols_participant) { protocol.protocols_participants.last }
  let!(:original_arm)          { protocols_participant.arm }
  let!(:second_arm)            { protocol.arms.second }

  context 'when interacting with participant notes' do
    scenario 'sees the notes modal' do
      given_i_am_viewing_the_participant_tracker
      when_i_click_on_the_notes_button
      then_i_should_see_the_notes_modal
    end

    scenario 'creates a note and sees it in the index' do
      given_i_am_viewing_the_participant_tracker
      when_i_click_on_the_notes_button
      when_i_add_a_comment_and_save
      then_i_should_see_the_note_in_the_index
    end
  end

  context 'when changing the participant arm' do
    scenario 'automatically creates and displays an arm change note' do
      given_i_am_viewing_the_participant_tracker
      when_i_change_the_participants_arm
      when_i_click_on_the_notes_button
      then_i_should_see_the_arm_change_note_in_the_index
    end
  end

  def given_i_am_viewing_the_participant_tracker
    visit protocol_path(protocol.id)
    
    expect(page).to have_content('Manage Arms')
    
    click_link 'Participant Tracker'
    expect(page).to have_css('#participantTrackerTable', visible: :all)
  end

  def participant_row
    find("#edit_protocols_participant_#{protocols_participant.id}", visible: :all, match: :first).ancestor('tr')
  end

  def when_i_click_on_the_notes_button
    within(participant_row) do
      find("#participant#{protocols_participant.participant_id}Notes a").click
    end
  end

  def when_i_add_a_comment_and_save
    within('#modalContainer') do
      expect(page).to have_field('note_comment')
      fill_in 'note_comment', with: 'Action Jackson'
      
      find('.modal-header').click

      click_button 'Leave Note'

      expect(page).to have_field('note_comment', with: '')
    end
  end

  def when_i_change_the_participants_arm
    bootstrap_select(
      '#protocols_participant_arm_id', 
      second_arm.name, 
      context_selector: participant_row
    )
    
    within(participant_row) do
      expect(bootstrap_selected?('protocols_participant_arm_id', second_arm.name)).to be
    end
  end

  def then_i_should_see_the_notes_modal
    expect(page).to have_content('Participant Notes')
  end

  def then_i_should_see_the_note_in_the_index
    expect(page).to have_content('Action Jackson')
  end

  def then_i_should_see_the_arm_change_note_in_the_index
    expect(page).to have_content("Arm changed from #{original_arm.name} to #{second_arm.name}")
  end
end
