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
      when_i_change_the_participants_arm
      when_i_click_on_the_notes_button
      then_i_should_see_the_arm_change_note_in_the_index
    end
  end

  def given_i_am_viewing_the_participant_tracker
    @protocol = create_and_assign_protocol_to_me
    @protocols_participant = @protocol.protocols_participants.last
    @original_arm = @protocols_participant.arm

    visit protocol_path(@protocol)
    
    expect(page).to have_link('Participant Tracker', visible: true, wait: 5)
    click_link 'Participant Tracker'

    expect(page).to have_css('#participantTrackerTable tbody tr:first-child', visible: true, wait: 15)
  end

  def when_i_click_on_the_notes_button
    find("#participant#{@protocols_participant.participant_id}Notes a", wait: 10).click

    expect(page).to have_css('.modal-dialog', visible: true, wait: 10)
  end

  def when_i_add_a_comment_and_save
    within('.modal-content') do
      expect(page).to have_field('note_comment', visible: true, wait: 10)
      
      note_field = find_field('note_comment')
      note_field.set("Action Jackson")
      note_field.send_keys(:tab)
      
      submit_btn = find("input[type='submit']", wait: 5)
      
      submit_btn.hover
      submit_btn.click
    end

    expect(page).to have_content("Action Jackson", wait: 15)
  end

  def when_i_change_the_participants_arm
    @second_arm = @protocol.arms.second
    hidden_select = find("select[id*='protocols_participant_arm_id']", visible: :all, match: :first)
    target_option = hidden_select.find('option', text: @second_arm.name, visible: :all)
    
    page.execute_script("$(arguments[0]).val(arguments[1]).trigger('change');", hidden_select, target_option.value)

    visit protocol_path(@protocol)
    click_link 'Participant Tracker'
    expect(page).to have_css('#participantTrackerTable tbody tr:first-child', visible: true, wait: 15)
  end

  def then_i_should_see_the_notes_modal
    expect(page).to have_css('.modal-title', text: 'Participant Notes', wait: 5)
  end

  def then_i_should_see_the_note_in_the_index
    expect(page).to have_content('Action Jackson', wait: 10)
  end

  def then_i_should_see_the_arm_change_note_in_the_index
    expect(page).to have_content("Arm changed from #{@original_arm.name} to #{@second_arm.name}", wait: 10)
  end
end
