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

feature 'Identity deletes a document', js: true, enqueue: false do

  context "from the All Reports page" do
    context "except they don't because the document is still processing" do
      scenario "and they see the delete icon is greyed out" do
        given_i_am_viewing_the_all_reports_page_with_documents(1, "Processing")
        then_i_should_see_the_delete_icon_is_greyed_out
      end
    end

    scenario "and does not see the report" do
      given_i_am_viewing_the_all_reports_page_with_documents(1)
      when_i_click_the_delete_icon
      then_i_should_not_see_the_document
    end

    context "which has not been accessed" do
      scenario "and sees the documents counter decrement" do
        given_i_am_viewing_the_all_reports_page_with_documents(2)
        when_i_click_the_delete_icon
        then_i_should_see_the_identity_docs_counter_was_decremented
      end
    end
  end

  context "from the Reports Tab" do
    context "except they don't because the document is still processing" do
      scenario "and they see the delete icon is greyed out" do
        given_i_am_viewing_the_reports_tab_with_documents(1, "Processing")
        then_i_should_see_the_delete_icon_is_greyed_out
      end
    end

    scenario "and does not see the report" do
      given_i_am_viewing_the_reports_tab_with_documents(1)
      when_i_click_the_delete_icon
      then_i_should_not_see_the_document
    end

    context "which has not been accessed" do
      scenario "and sees the documents counter decrement" do
        given_i_am_viewing_the_reports_tab_with_documents(2)
        when_i_click_the_delete_icon
        then_i_should_see_the_protocol_docs_counter_was_decremented
      end
    end
  end

  def given_i_am_viewing_the_all_reports_page_with_documents(count, state="Completed")
    @protocol = create_and_assign_protocol_to_me

    count.times do
      create(:document_of_identity_report, documentable_id: Identity.first.id, state: state)
    end

    visit documents_path
    wait_for_ajax
  end

  def given_i_am_viewing_the_reports_tab_with_documents(count, state="Completed")
    @protocol = create_and_assign_protocol_to_me

    count.times do
      create(:document_of_protocol_report, documentable_id: @protocol.id, state: state)
    end

    visit protocol_path @protocol
    wait_for_ajax

    click_link 'Reports'
  end

  def when_i_click_the_delete_icon
    first("a.remove-document").click
    accept_confirm
    wait_for_ajax
  end

  def then_i_should_see_the_delete_icon_is_greyed_out
    expect(page).to have_css("i.glyphicon-remove[style='cursor:default']")
  end

  def then_i_should_not_see_the_document
    expect(page).to_not have_css("a.attached_file")
  end

  def then_i_should_see_the_identity_docs_counter_was_decremented
    expect(page).to have_css(".identity_report_notifications", text: 1)
  end

  def then_i_should_see_the_protocol_docs_counter_was_decremented
    expect(page).to have_css(".protocol_report_notifications", text: 1)
  end
end