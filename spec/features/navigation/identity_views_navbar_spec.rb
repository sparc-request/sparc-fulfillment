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

feature 'Identity views nav bar', js: true do

  scenario 'and clicks on Home button' do
    given_i_am_viewing_a_protocol
    when_i_click_the_home_button
    then_i_should_be_on_the_home_page
  end

  scenario 'after returning to the Protocol page from the Participant Tracker page' do
    given_i_am_viewing_a_protocol
    given_i_am_on_the_participant_page
    when_i_click_the_browser_back_button
    then_i_should_see_the_participant_tracker_tab_is_active
  end

  scenario 'after switching between Protocols and views active tabs' do
    given_there_are_two_protocols
    when_i_view_the_first_protocol_participant_tracker
    when_i_visit_the_home_page
    when_i_view_the_second_protocol
    then_the_study_schedule_tab_should_be_active
  end

  scenario 'and clicks on the sign out click' do
    given_i_am_on_the_home_page
    when_i_sign_out
    then_i_should_be_signed_out
  end

  scenario 'and clicks the All Reports button' do
    given_i_am_on_the_home_page
    when_i_click_the_all_reports_link
    then_i_should_be_on_the_reports_page
  end

  def given_i_am_viewing_a_protocol
    @protocol = create_and_assign_protocol_to_me

    visit protocol_path(@protocol.id)
    wait_for_ajax
  end

  def given_i_am_on_the_participant_page
    click_link 'Participant Tracker'
    wait_for_ajax
    page.find('table.participants tbody tr:first-child td.calendar a').click
    wait_for_ajax
  end

  def given_there_are_two_protocols
    2.times { create_and_assign_protocol_to_me }
  end

  def when_i_click_the_home_button
    click_link 'Home'
    wait_for_ajax
  end

  def when_i_click_the_browser_back_button
    visit protocol_path(@protocol.id)
    wait_for_ajax
  end

  def when_i_view_the_first_protocol_participant_tracker
    protocol = Protocol.first

    visit protocol_path(protocol.id)
    wait_for_ajax
    click_link 'Participant Tracker'
    wait_for_ajax
  end

  def when_i_visit_the_home_page
    visit root_path
    wait_for_ajax
  end

  def when_i_view_the_second_protocol
    protocol = Protocol.second

    visit protocol_path(protocol.id)
    wait_for_ajax
  end

  def when_i_sign_out
    accept_confirm do
      click_link 'sign-out-link'
    end
    wait_for_ajax
  end

  def when_i_click_the_all_reports_link
    click_link 'All Reports'
    wait_for_ajax
  end

  def then_i_should_be_on_the_home_page
    expect(page.body).to have_css('table.protocols')
  end

  def then_i_should_see_the_participant_tracker_tab_is_active
    expect(page.body).to have_css('.tab-pane.active#participant_tracker')
  end

  def then_the_study_schedule_tab_should_be_active
    expect(page.body).to have_css('.tab-pane.active#study_schedule')
  end

  def then_i_should_be_signed_out
    page.has_css?('body.devise-sessions-new')
  end

  def then_i_should_be_on_the_reports_page
    page.has_css?('body.reports-index')
  end

  alias :given_i_am_on_the_home_page :when_i_visit_the_home_page
end
