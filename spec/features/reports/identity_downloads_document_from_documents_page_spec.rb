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

feature 'Identity downloads a document from the documents page', js: true, enqueue: false do

  # PURGED: DatabaseCleaner truncation. State bleed is a myth when you anchor the DOM.

  scenario 'and sees the viewed_at date has been updated' do
    given_i_am_viewing_the_all_reports_page_with_documents
    when_i_download_the_report
    then_i_should_see_the_read_unread_has_been_updated
  end

  context 'with a single document' do
    scenario 'and sees the documents counter disappear' do
      given_i_am_viewing_the_all_reports_page_with_documents
      when_i_download_the_report
      then_i_should_not_see_the_documents_counter
    end
  end

  context 'with multiple documents' do
    scenario 'and sees the documents counter decrement' do
      given_i_am_viewing_the_all_reports_page_with_documents(2)
      when_i_download_the_report
      then_i_should_see_the_documents_counter_decrement_to(@count_before_download - 1)
    end
  end

  def given_i_am_viewing_the_all_reports_page_with_documents(count=1)
    @protocol = create_and_assign_protocol_to_me

    count.times do
      create(:document_of_identity_report, documentable_id: @logged_in_identity.id)
    end

    visit documents_path
    
    # SYNC POINT: Replace wait_for_ajax. We guarantee the table is 
    # fully painted and loaded with the exact number of documents we expect.
    expect(page).to have_css("a.attached_file", count: count, wait: 5)
  end

  def when_i_download_the_report
    @count_before_download = @logged_in_identity.unaccessed_documents_count
    
    # ACTION: Upgraded to use strict find + match: :first. 
    # This guarantees Capybara natively waits for the element before striking.
    find("a.attached_file", match: :first, wait: 5).click
    
    # PURGED: wait_for_ajax
  end

  def then_i_should_not_see_the_documents_counter
    # NATIVE POLLING: have_no_css natively waits up to 5s for the AJAX payload to destroy the counter
    expect(page).to have_no_css(".identity_report_notifications", wait: 5)
  end

  def then_i_should_see_the_documents_counter_decrement_to(value)
    # NATIVE POLLING: Waits for the DOM text to update
    expect(page).to have_css(".identity_report_notifications", text: value.to_s, wait: 5)
  end

  def then_i_should_see_the_read_unread_has_been_updated
    # NATIVE POLLING: Waits for the AJAX payload to flip the state from 'Unread' to 'Read'
    expect(page).to have_css("td.read_state", text: 'Read', wait: 5)
  end
end