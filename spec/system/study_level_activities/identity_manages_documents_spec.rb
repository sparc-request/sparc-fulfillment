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

RSpec.describe 'Identity manages Documents', type: :system, js: true do
  let(:identity)  { @logged_in_identity }
  let(:protocol)  { create_and_assign_protocol_to_me(identity: identity) }
  let(:file_path) { Rails.root.join("spec/fixtures/files/test_document.txt") }

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
      when_i_click_on_line_item_documents_icon
      when_i_click_on_the_add_document_button
      when_i_upload_a_document
      then_i_should_see_the_line_item_documents_list
      then_i_should_see_the_document
    end
  end

  context 'User deletes document' do
    scenario 'and does not see the document anymore' do
      given_i_am_viewing_the_study_level_activities_tab
      when_i_click_on_line_item_documents_icon
      when_i_click_on_the_add_document_button
      when_i_upload_a_document
      then_i_should_see_the_line_item_documents_list
      then_i_should_see_the_document
      when_i_click_the_delete_icon
      then_i_should_not_see_the_document
    end
  end

  def given_i_am_viewing_the_study_level_activities_tab
    protocol.sparc_protocol.update(type: 'Study')
    visit protocol_path(protocol)

    expect(page).to have_content(/Manage Arms/i)

    expect(page).to have_css('.nav-link', text: /Non-clinical Services/i, visible: true)
    click_link "Non-clinical Services"

    # Wait for the table/data to fully load, not just the empty container
    expect(page).to have_css('.documents a', visible: true)
  end

  def when_i_click_on_line_item_documents_icon
    find('.documents a', match: :first).click

    # Assert the specific modal has fully faded in and animation is complete
    expect(page).to have_css('.modal.show .modal-title', text: /Line Item Documents/i, visible: true)
  end

  def when_i_click_on_the_add_document_button
    within('.modal-content', text: /Line Item Documents/i) do
      find('.document.new').click
    end

    # Strictly assert the NEW stacked modal has fully transitioned to `.show` before interacting
    expect(page).to have_css('.modal.show .modal-title', text: /Add Document/i, visible: true)
    expect(page).to have_css("input[type='file']", visible: :all)
  end

  def when_i_upload_a_document
    file_input_id = nil

    within('.modal-content', text: /Add Document/i) do
      file_input_id = find("input[type='file']", visible: :all)[:id]
      attach_file(file_input_id, file_path, make_visible: true)
    end

    # Move expectation OUTSIDE the within block (Best Practice III.B)
    # This natively forces Capybara to wait until the file text populates
    expect(page).to have_field(file_input_id, with: /test_document\.txt$/i, visible: :all)

    # CRITICAL SYNC POINT: Native Blur Event via dead zone click (Best Practice V.B)
    # This forces the browser to flush the event loop and fire the JavaScript 'onChange' 
    # listener, guaranteeing the application knows the file is there before we click Save.
    find('body').click(x: 0, y: 0)

    within('.modal-content', text: /Add Document/i) do
      click_button 'Save'
    end

    # Wait for the nested modal to vanish
    expect(page).to have_no_css('.modal-title', text: /Add Document/i, wait: 25)
  end

  def then_i_should_see_the_line_item_documents_list
    # Wait for the parent modal to safely become the active context again
    expect(page).to have_css('.modal.show .modal-title', text: /Line Item Documents/i, visible: true)
  end

  def then_i_should_see_the_document
    # Scope the text search to the active modal to prevent reading background/table data
    within('.modal-content', text: /Line Item Documents/i) do
      expect(page).to have_text(/test_document/i)
    end
  end

  def when_i_click_the_delete_icon
    within('.modal-content', text: /Line Item Documents/i) do
      expect(page).to have_css('.delete a', visible: true)
      find('.delete a', match: :first).click
    end
  end

  def then_i_should_not_see_the_document
    within('.modal-content', text: /Line Item Documents/i) do
      expect(page).to have_no_text(/test_document/i)
      expect(page).to have_text(/This line item has no documents/i)
    end
  end
end
