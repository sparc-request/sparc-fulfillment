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
  let(:identity) { @logged_in_identity }
  let(:protocol) { create_and_assign_protocol_to_me(identity: identity) }
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

    expect(page).to have_content(/Manage Arms/)

    expect(page).to have_css('.nav-link', text: /Non-clinical Services/i)
    click_link "Non-clinical Services"

    expect(page).to have_css('.documents', visible: true)
  end

  def when_i_click_on_line_item_documents_icon
    find('.documents a', match: :first).click

    expect(page).to have_css('.modal-content', text: /Line Item Documents/i, visible: true)
  end

  def when_i_click_on_the_add_document_button
    within('.modal-content', text: /Line Item Documents/i) do
      find('.document.new').click
    end

    expect(page).to have_no_css('.modal-title', text: /Line Item Document/i)

    expect(page).to have_css('.modal-title', text: /Add Document/i, visible: true)
    expect(page).to have_css("input[type='file']", visible: :all)
  end

  def when_i_upload_a_document
    expect(page).to have_css('.modal.show')

    within('.modal-content', text: /Add Document/i) do
      attach_file("Document", file_path, make_visible: true)
      # For this very specific use-case, the only consisten workaround seems to be the hacky "send_keys"... Capybara won't consistently find the "Save" button using any other means
      find_button("Save").send_keys(:return)
    end

    expect(page).to have_no_css('.modal-title', text: /Add Document/i, wait: 15)
  end

  def then_i_should_see_the_line_item_documents_list
    expect(page).to have_css('.modal-title', text: /Line Item Documents/i)
  end

  def then_i_should_see_the_document
    expect(page).to have_text(/test_document/i)
  end

  def when_i_click_the_delete_icon
    expect(page).to have_css('.delete a', visible: true)
    find('.delete a', match: :first).click
  end

  def then_i_should_not_see_the_document
    expect(page).to have_no_text(/test_document/i)
    expect(page).to have_text(/This line item has no documents/i)
  end
end
