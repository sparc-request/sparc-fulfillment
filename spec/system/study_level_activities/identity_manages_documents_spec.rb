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

feature 'Identity manages Documents', js: true do

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
      then_i_should_see_the_document
    end
  end

  context 'User deletes document' do
    scenario 'and does not see the document anymore' do
      given_i_am_viewing_the_study_level_activities_tab
      when_i_have_a_document_to_upload
      when_i_click_on_line_item_documents_icon
      when_i_click_on_the_add_document_button
      when_i_upload_a_document
      when_i_click_the_delete_icon
      then_i_should_not_see_the_document
    end
  end

  def given_i_am_viewing_the_study_level_activities_tab
    protocol = create_and_assign_protocol_to_me
    sparc_protocol = protocol.sparc_protocol
    sparc_protocol.update(type: 'Study')
    visit protocol_path(protocol.id)
    
    tab_link = find('a', text: 'Non-clinical Services', wait: 5)
    tab_link.hover
    tab_link.click
    
    expect(page).to have_css('.documents a', wait: 5)
  end

  def when_i_click_on_line_item_documents_icon
    doc_link = first('.documents a', wait: 5)
    doc_link.hover
    doc_link.click
    
    expect(page).to have_css('.modal-title', text: 'Line Item Documents', wait: 5)
  end

  def when_i_have_a_document_to_upload
    @filename = Rails.root.join('db', 'fixtures', 'test_document.txt')
  end

  def when_i_click_on_the_add_document_button
    new_doc_btn = find('.document.new', wait: 5)
    new_doc_btn.hover
    new_doc_btn.click
    
    expect(page).to have_css("input[type='file']", visible: :all, wait: 5)
  end

  def when_i_upload_a_document
    attach_file(find("input[type='file']", visible: :all)[:id], @filename, make_visible: true)
    
    save_btn = find_button('Save', wait: 5)
    save_btn.hover
    save_btn.click
  end

  def then_i_should_see_the_line_item_documents_list
    expect(page).to have_selector('.modal-title', text: 'Line Item Documents', wait: 5)
  end

  def then_i_should_see_the_document
    expect(page).to have_content('test_document.txt', wait: 5)
  end

  def when_i_click_the_delete_icon
    delete_icon = first('.delete a', wait: 5)
    delete_icon.hover
    delete_icon.click
  end

  def then_i_should_not_see_the_document
    expect(page).to have_text("This line item has no documents", wait: 5)
    expect(page).to_not have_content('test_document.txt')
  end
end
