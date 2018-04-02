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

feature 'User views the participant tracker page', js: true do

  context 'and then tries to create a particpant note' do
    scenario 'and sees the notes modal' do
      given_i_am_viewing_the_participant_tracker
      when_i_click_on_the_notes_button
      then_i_should_see_the_notes_modal
    end

    context 'and creates a note' do
      scenario 'and sees the note in the index' do
        given_i_am_viewing_the_participant_tracker
        when_i_click_on_the_notes_button
        when_i_add_a_comment_and_save
        then_i_should_see_the_note_in_the_index
      end
    end
  end

  context 'and changes the participant arm which should create a note' do
    scenario 'and sees the note' do
      given_i_am_viewing_the_participant_tracker
      when_i_change_the_particpants_arm
      when_i_click_on_the_notes_button
      then_i_should_see_the_arm_change_note_in_the_index
    end
  end

  def given_i_am_viewing_the_participant_tracker
    @protocol = create_and_assign_protocol_to_me
    @participant = create(:participant, protocol: @protocol, arm: @protocol.arms.first)
    @original_arm = @participant.arm

    visit protocol_path @protocol
    wait_for_ajax

    click_link 'Participant Tracker'
    wait_for_ajax
  end

  def when_i_click_on_the_notes_button
    find(".participant_notes[data-notable-id='#{@participant.id}']").click
    wait_for_ajax
  end

  def when_i_add_a_comment_and_save
    find('.new').click
    wait_for_ajax
    fill_in 'Comment', with: "Action Jackson"
    click_button 'Save'
    wait_for_ajax
  end

  def when_i_change_the_particpants_arm
    find(".change-arm[participant_id='#{@participant.id}']").click
    wait_for_ajax

    bootstrap_select "#participant_arm_id", @protocol.arms.second.name

    click_button 'Save'
    wait_for_ajax
  end

  def then_i_should_see_the_notes_modal
    expect(page).to have_content('Participant Notes')
  end

  def then_i_should_see_the_note_in_the_index
    expect(page).to have_content('Action Jackson')
  end

  def then_i_should_see_the_arm_change_note_in_the_index
    first_arm_name = @original_arm.name
    second_arm_name = @protocol.arms.second.name

    expect(page).to have_content("Arm changed from #{first_arm_name} to #{second_arm_name}")
  end
end
