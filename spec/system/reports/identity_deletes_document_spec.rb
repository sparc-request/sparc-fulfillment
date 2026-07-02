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

RSpec.describe 'Identity deletes a document', type: :system, js: true, inline_jobs: true do
  let(:identity) { @logged_in_identity }
  let(:protocol) { create_and_assign_protocol_to_me(identity: identity) }

  context 'from the All Reports page' do
    context 'when the document is still processing' do
      scenario 'sees the delete icon is greyed out' do
        given_i_am_viewing_the_all_reports_page_with_documents(1, state: 'Processing')
        then_i_should_see_no_delete_icon
      end
    end

    context 'when clicking the delete report' do
      scenario 'does not see the report after deletion' do
        given_i_am_viewing_the_all_reports_page_with_documents(1)
        when_i_click_the_delete_icon
        then_i_should_not_see_the_document
      end
    end

    context 'which has not been accessed' do
      scenario 'sees the documents counter decrement' do
        given_i_am_viewing_the_all_reports_page_with_documents(2)
        when_i_click_the_delete_icon
        then_i_should_see_the_identity_docs_counter(expected_count: 1)
      end
    end
  end

  context 'from the Reports Tab' do
    context 'when the document is still processing' do
      scenario 'sees the delete icon is greyed out' do
        given_i_am_viewing_the_reports_tab_with_documents(1, state: 'Processing')
        then_i_should_see_no_delete_icon
      end
    end

    context 'when clicking the delete report' do
      scenario 'does not see the report after deletion' do
        given_i_am_viewing_the_reports_tab_with_documents(1)
        when_i_click_the_delete_icon
        then_i_should_not_see_the_document
      end
    end

    context 'which has not been accessed' do
      scenario 'sees the documents counter decrement' do
        given_i_am_viewing_the_reports_tab_with_documents(2)
        when_i_click_the_delete_icon
        then_i_should_see_the_protocol_docs_counter(expected_count: 1)
      end
    end
  end

  def given_i_am_viewing_the_all_reports_page_with_documents(count, state: 'Completed')
    # Explicitly invoke the lazy variables so they generate under the authenticated user
    protocol
    
    count.times do
      create(:document_of_identity_report, documentable: identity, state: state)
    end

    visit documents_path

    expect(page).to have_css('table tbody', visible: true)
    expect(page).to have_no_content('No matching records found')
    
    if state == 'Completed'
      expect(page).to have_css('a.remove-document', count: count, visible: true)
    end
  end

  def given_i_am_viewing_the_reports_tab_with_documents(count, state: 'Completed')
    visit protocol_path(protocol)

    if state == 'Completed'
      count.times do |i|
        if i == 0
          click_button 'Export'
        else
          # On subsequent iterations, the button is a dropdown toggle
          click_button 'Export'
          
          # Native Capybara text matching to safely click the inner dropdown link
          find('a, button', text: /Generate New Report/i, match: :first).click
        end
        
        # Sync point to guarantee the job finishes before moving on
        expect(page).to have_css('.notification-badge', text: /#{i + 1}/, visible: :all)
      end
    else
      count.times do
        create(:document_of_protocol_report, documentable: protocol, state: state)
      end
      visit protocol_path(protocol)
    end

    expect(page).to have_css('#reportsTabLink', visible: true)
    find('#reportsTabLink').click
    expect(page).to have_css('#reportsTabLink.active', visible: true)

    expect(page).to have_css('table tbody', visible: true)
    expect(page).to have_no_content('No matching records found')
    
    if state == 'Completed'
      expect(page).to have_css('a.remove-document', count: count, visible: true)
    end
  end

  def when_i_click_the_delete_icon
    accept_confirm do
      find('a.remove-document', match: :first).click
    end
  end

  def then_i_should_see_no_delete_icon
    expect(page).to have_no_css('.actions .remove-document')
  end

  def then_i_should_not_see_the_document
    expect(page).to have_no_css('a.attached_file', visible: :all)
  end

  def then_i_should_see_the_identity_docs_counter(expected_count:)
    expect(page).to have_css('.identity_report_notifications', text: /#{expected_count}/)
  end

  def then_i_should_see_the_protocol_docs_counter(expected_count:)
    expect(page).to have_css('.notification-badge', text: /#{expected_count}/)
  end
end
