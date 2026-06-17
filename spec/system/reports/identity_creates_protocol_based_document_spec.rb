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

RSpec.describe 'Identity creates a protocol-based Document', type: :system, js: true, inline_jobs: true do
  let(:identity) { @logged_in_identity }
  let(:protocol) { create_and_assign_protocol_to_me(identity: identity) }

  before do
    given_i_am_viewing_the_reports_tab
  end

  context 'of type Participant Report' do
    scenario 'and sees the report' do
      when_i_create_a_document_of_type('participant_report')
      then_i_should_see_the_document
    end
  end

  context 'of type Study Schedule Report' do
    scenario 'and sees the report' do
      when_i_create_a_document_of_type('study_schedule_report')
      then_i_should_see_the_document
    end
  end

  context 'with no documents present' do
    scenario 'and does not see the counter' do
      then_i_should_not_see_the_documents_counter
    end
  end

  context 'with documents present' do
    scenario 'and sees the reports counter increment' do
      when_i_create_a_document_of_type('study_schedule_report')
      then_i_should_see_the_counter_increment_to(1)
      
      when_i_create_a_document_of_type('participant_report')
      then_i_should_see_the_counter_increment_to(2)
    end
  end

  def given_i_am_viewing_the_reports_tab
    visit protocol_path(protocol)

    expect(page).to have_css('#reportsTabLink', visible: true)
    find('#reportsTabLink').click
    expect(page).to have_css('#reportsTabLink.active')
  end

  def when_i_create_a_document_of_type(type)
    if type == 'study_schedule_report'
      click_button "Export"
    elsif type == 'participant_report'
      click_link 'Participant Tracker'
      find('.participant-report', match: :first).click
    end

    expect(page).to have_css('.notification-badge', visible: :all)

    # Re-click the active tab to force the data table to fetch the new records.
    find('#reportsTabLink').click
    
    # Wait for the visual DOM update (the empty state should disappear)
    expect(page).to have_no_content('No matching records found')
  end

  def then_i_should_see_the_document(expected_count: 1)
    # Target the file icon inside the table row 
    expect(page).to have_css('table tbody tr .fa-file', count: expected_count, visible: :all)
    
    # Now that the UI has settled, safely assert reality
    expect(Document.where(documentable: protocol).count).to eq(expected_count)
  end

  def then_i_should_not_see_the_documents_counter
    expect(page).to have_no_css('.notification-badge')
  end

  def then_i_should_see_the_counter_increment_to(value)
    expect(page).to have_css('.notification-badge', text: /#{value}/)
  end
end
