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

feature 'Identity manages Doucuments', js: true do

  context 'User views line item documents' do
    scenario 'and sees the line item documents list' do
      given_i_am_viewing_the_study_level_activities_tab
      when_i_click_on_line_item_documents_icon
      then_i_should_see_the_line_item_documents_list
    end
  end

  context 'User uploads new line item document' do
    scenario 'and sees the document' do
      given_i_am_viewing_the_study_level_activities_tab
      when_i_have_a_document_to_upload
      when_i_click_on_line_item_documents_icon
      when_i_click_on_the_add_document_button
      when_i_upload_a_document
      when_i_click_on_line_item_documents_icon
      then_i_should_see_the_document
    end
  end

  def given_i_am_viewing_the_study_level_activities_tab
    protocol = create_and_assign_protocol_to_me
    sparc_protocol = protocol.sparc_protocol
    sparc_protocol.update_attributes(type: 'Study')
    visit protocol_path(protocol.id)
    wait_for_ajax
    click_link "Study Level Activities"
    wait_for_ajax
  end

  def when_i_click_on_line_item_documents_icon
    first("#study-level-activities-table .available-actions-button").click
    wait_for_ajax
    first('.documents[data-documentable-type="LineItem"]').click
    wait_for_ajax
  end

  def when_i_have_a_document_to_upload
    @filename = Rails.root.join('db', 'fixtures', 'test_document.txt')
  end

  def when_i_open_up_a_fulfillment
    first('.otf_fulfillments.list').click
    wait_for_ajax
    click_button 'List'
    wait_for_ajax
  end

  def when_i_click_on_the_add_document_button
    find('.document.new').click
    wait_for_ajax
  end

  def when_i_upload_a_document
    attach_file(find("input[type='file']")[:id], @filename)
    click_button "Save"
  end

  def then_i_should_see_the_line_item_documents_list
    expect(page).to have_content('Line Item Documents')
  end

  def then_i_should_see_the_document
    expect(page).to have_content('test_document.txt')
  end
end
