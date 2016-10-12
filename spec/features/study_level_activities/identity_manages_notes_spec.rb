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

feature 'Notes', js: true do

  describe 'managing line item notes' do

    it 'should be able to create a line item note' do
      given_i_am_viewing_the_study_level_activities_tab
      count = @line_item.notes.count
      when_i_open_up_a_new_line_item_note
      then_i_fill_out_and_save_the_note
      expect(@line_item.notes.count).to eq(count + 1)
    end
  end

  describe 'managing fulfillment notes' do

    it 'should be able to create a fulfillment note' do
      given_i_am_viewing_the_study_level_activities_tab
      count = @fulfillment.notes.count
      when_i_open_up_a_new_fulfillment_note
      then_i_fill_out_and_save_the_note
      expect(@fulfillment.notes.count).to eq(count + 1)
    end
  end

  def given_i_am_viewing_the_study_level_activities_tab
    protocol = create_and_assign_protocol_to_me
    sparc_protocol = protocol.sparc_protocol
    @line_item = protocol.line_items.first
    @fulfillment=  @line_item.fulfillments.first
    sparc_protocol.update_attributes(type: 'Study')
    visit protocol_path(protocol.id)
    wait_for_ajax
    click_link "Study Level Activities"
    wait_for_ajax
  end

  def when_i_open_up_a_new_line_item_note
    first("#study-level-activities-table .available-actions-button").click
    wait_for_ajax
    first('.notes.list[data-notable-type="LineItem"]').click
    wait_for_ajax
    find('.note.new').click
    wait_for_ajax
  end

  def when_i_open_up_a_new_fulfillment_note
    first('.otf-fulfillment-list').click
    wait_for_ajax
    first("#fulfillments-table .available-actions-button").click
    wait_for_ajax
    first('.notes.list[data-notable-type="Fulfillment"]').click
    wait_for_ajax
    find('.note.new').click
    wait_for_ajax
  end

  def then_i_fill_out_and_save_the_note
    fill_in 'note_comment', with: "Test Comment"
    wait_for_ajax
    click_button 'Save'
    wait_for_ajax
  end
end
