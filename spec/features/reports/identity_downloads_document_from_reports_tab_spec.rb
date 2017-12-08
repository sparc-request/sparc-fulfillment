# Copyright © 2011-2017 MUSC Foundation for Research Development~
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

feature 'Identity downloads a document from the reports tab', js: true, enqueue: false do

  scenario 'and sees the viewed_at date has been updated' do
    given_i_am_viewing_the_reports_tab_with_documents
    when_i_download_the_report
    then_i_should_see_the_viewed_at_date_has_been_updated
  end

  context 'with a single document' do
    scenario 'and sees the documents counter disappear' do
      given_i_am_viewing_the_reports_tab_with_documents
      when_i_download_the_report
      then_i_should_not_see_the_reports_counter
    end
  end

  context 'with multiple documents' do
    scenario 'and sees the documents counter decrement' do
      given_i_am_viewing_the_reports_tab_with_documents(2)
      when_i_download_the_report
      then_i_should_see_the_reports_counter_decrement_to(1)
    end
  end

  def given_i_am_viewing_the_reports_tab_with_documents(count=1)
    @protocol = create_and_assign_protocol_to_me

    count.times do
      create(:document_of_protocol_report, documentable_id: @protocol.id)
    end

    @document = Document.first

    visit protocol_path @protocol
    wait_for_ajax

    click_link 'Reports'
    wait_for_ajax
  end

  def when_i_download_the_report
    click_link "file_#{@document.id}"
    wait_for_ajax
  end

  def then_i_should_not_see_the_reports_counter
    expect(page).to_not have_css(".protocol_report_notifications")
  end

  def then_i_should_see_the_reports_counter_decrement_to(value)
    expect(page).to have_css(".protocol_report_notifications", text: value)
  end

  def then_i_should_see_the_viewed_at_date_has_been_updated
    expect(page).to have_css("td.viewed_at", text: Time.now.strftime("%m/%d/%Y"))
  end
end
