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

feature 'Identity edits document title', js: true, enqueue: false do

  context "from the All Reports page" do
    context "when creating a report" do
      scenario "and sees the custom title" do
        given_i_am_viewing_the_all_reports_page
        when_i_create_an_identity_based_document_with_a_custom_title
        then_i_should_see_the_title_has_been_updated
      end
    end
  end

  context "from the All Reports page" do
    scenario "and sees the title has changed" do
      given_i_am_viewing_the_all_reports_page_with_documents
      when_i_edit_the_title
      then_i_should_see_the_title_has_been_updated
    end
  end

  context "from the Reports Tab" do
    scenario "and sees the title has changed" do
      given_i_am_viewing_the_reports_tab_with_documents
      when_i_edit_the_title
      then_i_should_see_the_title_has_been_updated
    end
  end

  def given_i_am_viewing_the_all_reports_page
    @protocol = create_and_assign_protocol_to_me

    visit documents_path
    
    expect(page).to have_css('table', wait: 5)
  end

  def given_i_am_viewing_the_all_reports_page_with_documents
    @protocol = create(:protocol_imported_from_sparc)
    org       = @protocol.sub_service_request.organization
                create(:clinical_provider, identity: Identity.first, organization: org)
                create(:document_of_identity_report, documentable_id: Identity.first.id)

    visit documents_path
    
    expect(page).to have_css('table', wait: 5)
    expect(page).to have_css('a.edit-document', wait: 5)
  end

  def given_i_am_viewing_the_reports_tab_with_documents
    @protocol = create(:protocol_imported_from_sparc)
    org       = @protocol.sub_service_request.organization
                create(:clinical_provider, identity: Identity.first, organization: org)
                create(:document_of_protocol_report, documentable_id: @protocol.id)

    visit protocol_path @protocol

    reports_tab = find('#reportsTabLink', wait: 5)
    reports_tab.click
    expect(page).to have_css('#reportsTabLink.active', wait: 5)

    expect(page).to have_css('a.edit-document', wait: 5)
  end

  def when_i_create_an_identity_based_document_with_a_custom_title
    find('.documents a', text:'Invoice Report', wait: 5).click

    expect(page).to have_field('Title', wait: 5)
    fill_in 'Title', with: "A custom title"

    bootstrap_datepicker 'input#start_date', day: '10'
    bootstrap_datepicker 'input#end_date', day: '10'

    find('button[data-id="organization_select"]', wait: 5).click
    find(".dropdown-menu.show .dropdown-item", text: @protocol.organization.name, wait: 5).click

    find('.modal-title').click

    find('button[data-id="protocol_select"]', wait: 5).click
    find(".dropdown-menu.show .dropdown-item", text: /#{@protocol.sparc_id}/, wait: 5).click

    find('.modal-title').click

    find("input[type='submit']", wait: 5).click

    expect(page).to have_no_css('.modal.show', wait: 15)
  end

  def when_i_edit_the_title
    first("a.edit-document", wait: 5).click

    within('.modal.show', wait: 5) do
      expect(page).to have_field('document_title', wait: 5)
      fill_in 'document_title', with: "A custom title"

      save_screenshot('trench_1_filled.png')

      save_btn = find('button', text: 'Save', wait: 5)
      save_btn.hover

      save_screenshot('trench_2_hovered.png')

      save_btn.click

      save_screenshot('trench_3_clicked.png')
    end

    save_screenshot('trench_4_timeout.png')
    expect(page).to have_no_css('.modal.show', wait: 15)
  end

  def then_i_should_see_the_title_has_been_updated
    if page.has_css?('#reportsTabLink', wait: 2)
      find('#reportsTabLink').click
      expect(page).to have_css('#reportsTabLink.active', wait: 5)
    end

    expect(page).to have_content("A custom title", wait: 10)
  end
end
