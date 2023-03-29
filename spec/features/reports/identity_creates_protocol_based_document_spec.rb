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
    DatabaseCleaner[:active_record, model: Document].clean_with(:truncation)
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
    then_i_should_see_the_document
  end

  def given_i_am_viewing_the_reports_tab
    @protocol = create_and_assign_protocol_to_me

    visit protocol_path @protocol
    wait_for_ajax

    find('#reportsTabLink').click
    wait_for_ajax
  end

  def when_i_create_a_document_of_type(type)
    case type
    when 'study_schedule_report'
      click_button "Export"
      wait_for_ajax

      @document_id = first('.study-schedule-report')['data-url'].split('documentable_id=')[1].split('&')[0]
    when 'participant_report'
      click_link 'Participant Tracker'
      find('.participant-report').click
      wait_for_ajax

      @document_id = first('.participant-report')['data-url'].split('documentable_id=')[1].split('&')[0]
    end
  end

  def when_i_click_the_created_document_icon
    find(".fa-file-download").click
    wait_for_ajax
  end

  def when_i_click_the_download_option
    find("ul.dropdown-menu .download-report").click
    wait_for_ajax
  end

  def when_i_click_the_generate_new_option
    find("ul.dropdown-menu .regenerate-report").click
    wait_for_ajax
  end

  def then_i_should_see_the_document
    find('#reportsTabLink').click
    wait_for_ajax

    expect(page).to have_css("a#file_#{@document_id}")
  end

  def then_i_should_see_the_options_dropdown
    expect(page).to have_selector("ul.dropdown-menu", visible: true)
  end

  def then_i_should_see_the_button_is_defaulted
    expect(page).to have_css("button.study-schedule-report.btn-success")
    expect(page).not_to have_css("button.study-schedule-report.btn-secondary")
  end

  def then_i_should_not_see_the_documents_counter
    expect(page).to_not have_css(".notification-badge")
  end

  def then_i_should_see_the_counter_increment_to(value)
    expect(page).to have_css(".notification-badge", text: value)
  end
end
