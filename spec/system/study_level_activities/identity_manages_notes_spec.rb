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

RSpec.describe 'Notes', type: :system, js: true do
  let(:identity)  { @logged_in_identity }
  let(:protocol)  { create_and_assign_protocol_to_me(identity: identity) }
  let(:line_item) { create(:line_item, protocol: protocol) }

  describe 'managing line item notes' do
    it 'should be able to create a line item note' do
      given_i_am_viewing_the_study_level_activities_tab
      when_i_open_up_a_new_line_item_note
      then_i_fill_out_and_save_the_note
    end
  end

  describe 'managing fulfillment notes' do
    it 'should be able to create a fulfillment note' do
      given_i_am_viewing_the_study_level_activities_tab
      when_i_open_up_a_new_fulfillment_note
      then_i_fill_out_and_save_the_note
    end
  end

  def given_i_am_viewing_the_study_level_activities_tab
    protocol.sparc_protocol.update(type: 'Study')
    create(:fulfillment, line_item: line_item)

    visit protocol_path(protocol)
    
    expect(page).to have_content('Manage Arms')

    expect(page).to have_css('.nav-link', text: /Non-clinical Services/i)
    click_link 'Non-clinical Services'

    expect(page).to have_css('.notes', visible: true)
  end

  def when_i_open_up_a_new_line_item_note
    find('.notes a', match: :first).click
    
    expect(page).to have_css('.modal-title', text: /Service Notes/i, visible: true)
    expect(page).to have_content(/This Service doesn't have any notes/i)
  end

  def when_i_open_up_a_new_fulfillment_note
    find('.fulfillments a', match: :first).click

    expect(page).to have_css('.modal-title', text: /Fulfillments List/i, visible: true)
    find('a.fulfillment_notes', match: :first).click
    
    expect(page).to have_css('.modal-title', text: /Fulfillment Notes/i, visible: true)
    expect(page).to have_content(/This Fulfillment doesn't have any notes/i)
  end

  def then_i_fill_out_and_save_the_note
    within('.modal-content', text: /(Service|Fulfillment) Notes/i) do
      fill_in 'note_comment', with: 'Test comment'
      click_button 'Leave Note'
    end

    expect(page).to have_css('.note-body', text: /Test comment/i, visible: true, wait: 10)
  end
end
