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

RSpec.describe 'Identity edits document title', type: :system, js: true, inline_jobs: true do
  let(:identity) { @logged_in_identity }
  let(:protocol) { create_and_assign_protocol_to_me(identity: identity) }

  context 'from the All Reports page' do
    context 'when creating a new report' do
      scenario 'sees the custom title has been applied' do
        given_i_am_viewing_the_all_reports_page
        when_i_create_an_identity_based_document_with_a_custom_title
        then_i_should_see_the_title_has_been_updated
      end
    end

    context 'when editing an existing report' do
      scenario 'sees the title has changed' do
        given_i_am_viewing_the_all_reports_page_with_documents
        when_i_edit_the_title
        then_i_should_see_the_title_has_been_updated
      end
    end
  end

  context 'from the Reports Tab' do
    scenario 'sees the title has changed' do
      given_i_am_viewing_the_reports_tab_with_documents
      when_i_edit_the_title
      then_i_should_see_the_title_has_been_updated
    end
  end

  def given_i_am_viewing_the_all_reports_page
    protocol

    visit documents_path
    
    expect(page).to have_css('table tbody', visible: true)
  end

  def given_i_am_viewing_the_all_reports_page_with_documents
    protocol
    
    create(:document_of_identity_report, documentable: identity)

    visit documents_path

    expect(page).to have_css('table tbody', visible: true)

    expect(page).to have_css('td a.edit-document', visible: true)
  end

  def given_i_am_viewing_the_reports_tab_with_documents
    visit protocol_path(protocol)
    
    click_button 'Export'
    expect(page).to have_css('.notification-badge', text: /1/, visible: :all)

    expect(page).to have_css('#reportsTabLink', visible: true)
    find('#reportsTabLink').click
    expect(page).to have_css('#reportsTabLink.active', visible: true)

    expect(page).to have_css('table tbody', visible: true)
    expect(page).to have_css('td a.edit-document', visible: true)
  end

  def when_i_create_an_identity_based_document_with_a_custom_title
    click_link 'Invoice Report'

    expect(page).to have_css('.modal-title', text: /Invoice Report/i, visible: true)

    fill_in 'Title', with: 'A custom title'

    bootstrap_datepicker 'input#start_date', day: '10'
    # Force Capybara to wait until the JS actually populates the field, ensuring the first calendar is fully resolved before triggering the second
    expect(page).to have_no_field('start_date', with: '', wait: 10)

    bootstrap_datepicker 'input#end_date', day: '10'
    expect(page).to have_no_field('end_date', with: '', wait: 10)

    # Explicit descendant selectors replace the `within` block
    org_toggle = find('.modal-content button[data-id="organization_select"]')
    org_toggle.click
    find('.dropdown-menu.show .dropdown-item', text: protocol.organization.name).click
    org_toggle.click # Native toggle to close the multi-select safely

    protocol_toggle = find('.modal-content button[data-id="protocol_select"]')
    protocol_toggle.click
    find('.dropdown-menu.show .dropdown-item', text: /#{protocol.sparc_id}/).click
    protocol_toggle.click # Native toggle to close the multi-select safely

    click_button 'Request Report'
    
    expect(page).to have_no_css('.modal.show')
  end

  def when_i_edit_the_title
    find('a.edit-document', match: :first).click

    expect(page).to have_css('.modal-title', text: /Edit Report Title/i, visible: true)

    within('.modal-content', text: /Edit Report Title/i) do
      fill_in 'document_title', with: 'A custom title'

      click_button 'Save'
    end

    expect(page).to have_no_css('.modal.show', wait: 10)
  end

  def then_i_should_see_the_title_has_been_updated
    expect(page).to have_css('td', text: /A custom title/i)
  end
end
