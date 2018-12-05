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

feature 'Identity edits document title', js: true, enqueue: false do

  context "from the All Reports page" do
    context "when creating a report" do
      scenario "and sees the custom title" do
        given_i_am_viewing_the_all_reports_page
        when_i_create_an_identity_based_document_with_a_custom_title
        then_i_should_see_the_title_has_been_updated
      end
    end

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
    wait_for_ajax
  end

  def given_i_am_viewing_the_all_reports_page_with_documents
    @protocol = create(:protocol_imported_from_sparc)
    org       = @protocol.sub_service_request.organization
                create(:clinical_provider, identity: Identity.first, organization: org)
                create(:document_of_identity_report, documentable_id: Identity.first.id)

    visit documents_path
    wait_for_ajax
  end

  def given_i_am_viewing_the_reports_tab_with_documents
    @protocol = create(:protocol_imported_from_sparc)
    org       = @protocol.sub_service_request.organization
                create(:clinical_provider, identity: Identity.first, organization: org)
                create(:document_of_protocol_report, documentable_id: @protocol.id)

    visit protocol_path @protocol
    wait_for_ajax

    click_link 'Reports'
    wait_for_ajax
  end

  def when_i_create_an_identity_based_document_with_a_custom_title
    find("[data-type='invoice_report']").click
    wait_for_ajax

    fill_in 'Title', with: "A custom title"
    bootstrap_datepicker '#start_date', day: '10'
    bootstrap_datepicker '#end_date', day: '10'
    find('button.multiselect').click
    check(@protocol.organization.name)

    # close organization dropdown, so it's not covering protocol dropdown
    find('.modal-title').click

    #Actually choose protocol
    find('.bootstrap-select').click
    find('.dropdown-menu a', text: @protocol.short_title_with_sparc_id.truncate(50)).click

    # close protocol dropdown, so it's not covering 'Request Report' button
    find('.modal-title').click

    find("input[type='submit']").click
    wait_for_ajax
  end

  def when_i_edit_the_title
    first("a.edit-document").click
    wait_for_ajax

    fill_in 'Title', with: "A custom title"

    find("button[type='submit']").click
    wait_for_ajax
  end

  def then_i_should_see_the_title_has_been_updated
    expect(page).to have_content("A custom title")
  end
end
