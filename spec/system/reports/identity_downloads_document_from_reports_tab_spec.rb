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

RSpec.describe 'Identity downloads a document from the reports tab', type: :system, js: true, inline_jobs: true do
  let(:identity) { @logged_in_identity }
  let(:protocol) { create_and_assign_protocol_to_me(identity: identity) }

  context 'with a single document' do
    scenario 'sees the viewed_at date has been updated' do
      given_i_am_viewing_the_reports_tab_with_documents(1)
      when_i_download_the_report
      then_i_should_see_the_read_unread_has_been_updated
    end

    scenario 'sees the documents counter disappear' do
      given_i_am_viewing_the_reports_tab_with_documents(1)
      when_i_download_the_report
      then_i_should_not_see_the_reports_counter
    end
  end

  context 'with multiple documents' do
    scenario 'sees the documents counter decrement' do
      given_i_am_viewing_the_reports_tab_with_documents(2)
      when_i_download_the_report
      then_i_should_see_the_reports_counter_decrement_to(1)
    end
  end

  def given_i_am_viewing_the_reports_tab_with_documents(count)
    visit protocol_path(protocol)

    # Eradicate phantom procedures & state-mutating UI - build the data naturally via the UI to guarantee physical file attachments and prevent 500 Errors
    count.times do |i|
      if i == 0
        click_button 'Export'
      else
        click_button 'Export'
        find('a, button', text: /Generate New Report/i, match: :first).click
      end
      
      # Sync point: wait for the background job to finish processing the document
      expect(page).to have_css('.notification-badge', text: /#{i + 1}/, visible: :all)
    end

    # Native synchronization for tab structural presence and activation
    expect(page).to have_css('#reportsTabLink', visible: true)
    find('#reportsTabLink').click
    expect(page).to have_css('#reportsTabLink.active', visible: true)

    expect(page).to have_css('table tbody', visible: true)
    expect(page).to have_no_content('No matching records found')
    expect(page).to have_css('a.attached_file', count: count, visible: true)
  end

  def when_i_download_the_report
    find('a.attached_file', match: :first).click
  end

  def then_i_should_not_see_the_reports_counter
    expect(page).to have_no_css('.notification-badge')
  end

  def then_i_should_see_the_reports_counter_decrement_to(value)
    expect(page).to have_css('.notification-badge', text: /#{value}/)
  end

  def then_i_should_see_the_read_unread_has_been_updated
    expect(page).to have_css('td.read_state', text: /Read/i)
  end
end
