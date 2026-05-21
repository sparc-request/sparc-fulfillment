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

# For reports where:
# documentable_type = 'Protocol'
feature 'Identity creates a protocol-based Document', js: true, enqueue: false do

  before :each do
    DatabaseCleaner[:active_record, db: Document].clean_with(:truncation)
    given_i_am_viewing_the_reports_tab
  end

  context 'of type Participant Report' do
    scenario 'and sees the report' do
      when_i_create_a_document_of_type 'participant_report'
      then_i_should_see_the_document
    end
  end

  context 'of type Study Schedule Report' do
    scenario 'and sees the report' do
      when_i_create_a_document_of_type 'study_schedule_report'
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
      when_i_create_a_document_of_type 'study_schedule_report'
      then_i_should_see_the_counter_increment_to(1)
      # request a second report
      when_i_create_a_document_of_type 'participant_report'
      then_i_should_see_the_counter_increment_to(2)
    end
  end

  scenario 'and opens the finished document dropdown menu' do
    when_i_create_a_document_of_type 'study_schedule_report'
    when_i_click_the_created_document_icon
    then_i_should_see_the_options_dropdown
  end

  context 'and downloads the document' do
    scenario 'and sees the button default so that a new report can be run' do
      when_i_create_a_document_of_type 'study_schedule_report'
      when_i_click_the_created_document_icon
      when_i_click_the_download_option
      then_i_should_see_the_button_is_defaulted
    end
  end

  scenario 'and generates a new document' do
    when_i_create_a_document_of_type 'study_schedule_report'
    when_i_click_the_created_document_icon
    when_i_click_the_generate_new_option
    then_i_should_see_the_document(expected_count: 2)
  end

  def given_i_am_viewing_the_reports_tab
    @protocol = create_and_assign_protocol_to_me

    visit protocol_path @protocol
    
    expect(page).to have_css('#reportsTabLink', wait: 5)
    find('#reportsTabLink').click
    
    expect(page).to have_css('#reportsTabLink.active', wait: 5)
  end

  def when_i_create_a_document_of_type(type)
    case type
    when 'study_schedule_report'
      click_button "Export"
      
      expect(page).to have_selector('ul.dropdown-menu .download-report', visible: :all, wait: 20)

    when 'participant_report'
      click_link 'Participant Tracker'
      expect(page).to have_css('.participant-report', wait: 5)
      find('.participant-report').click
      
      expect(page).to have_selector('ul.dropdown-menu .download-report', visible: :all, wait: 20)
    end
  end

  def when_i_click_the_created_document_icon
    first(".fa-file-download").click
  end

  def when_i_click_the_download_option
    find("ul.dropdown-menu .download-report", wait: 5).click
  end

  def when_i_click_the_generate_new_option
    find("ul.dropdown-menu .regenerate-report", wait: 5).click
  end

  def then_i_should_see_the_document(expected_count: 1)
    find('#reportsTabLink').click
    expect(page).to have_css('#reportsTabLink.active', wait: 5)

    Timeout.timeout(5) do
      sleep 0.25 until Document.where(documentable: @protocol).count == expected_count
    end
    expect(Document.where(documentable: @protocol).count).to eq(expected_count)
  end

  def then_i_should_see_the_options_dropdown
    expect(page).to have_selector("ul.dropdown-menu", visible: true, wait: 5)
  end

  def then_i_should_see_the_button_is_defaulted
    expect(page).to have_css("button.study-schedule-report.btn-success", wait: 5)
    expect(page).not_to have_css("button.study-schedule-report.btn-secondary")
  end

  def then_i_should_not_see_the_documents_counter
    expect(page).to have_no_css(".notification-badge", wait: 2)
  end

  def then_i_should_see_the_counter_increment_to(value)
    expect(page).to have_css(".notification-badge", text: value.to_s, wait: 15)
  end
end
