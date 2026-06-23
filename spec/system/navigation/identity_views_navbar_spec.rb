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

RSpec.describe 'Identity views nav bar', type: :system, js: true do
  let(:protocol)        { create_and_assign_protocol_to_me }
  let(:second_protocol) { create_and_assign_protocol_to_me }

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
    when_i_view_the_first_participants_in_protocol_tracker
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
    visit protocol_path(protocol.id)
    
    # Sync point to prevent Capybara from roadrunning before the page loads
    expect(page).to have_css('#studyScheduleTabLink')
    expect(page).to have_content('Manage Arms')
  end

  def given_i_am_on_the_participant_page
    click_link 'Participant Tracker'
    
    # Sync point
    expect(page).to have_css('a.active#participantTrackerTabLink')
    expect(page).to have_css('tbody tr[data-index="0"] a.btn-primary')
    
    find('tbody tr[data-index="0"] a.btn-primary').click
  end

  def given_there_are_two_protocols
    protocol
    second_protocol
  end

  def when_i_click_the_home_button
    within('#siteNav') do
      find('.nav-link', text: 'Home').click
    end
  end

  def when_i_click_the_browser_back_button
    visit protocol_path(protocol.id)
  end

  def when_i_view_the_first_participants_in_protocol_tracker
    visit protocol_path(protocol.id)
    
    expect(page).to have_link('Participant Tracker')
    click_link 'Participant Tracker'
    
    # Sync point
    expect(page).to have_css('a.active#participantTrackerTabLink')
  end

  def when_i_visit_the_home_page
    visit root_path
    
    # Sync point
    expect(page).to have_css('table#protocols')
  end

  def when_i_view_the_second_protocol
    visit protocol_path(second_protocol.id)
  end

  def when_i_sign_out
    within('#siteNav') do
      find('#navbarUtilities').click
      
      expect(page).to have_css('a.text-danger')
      find('a.text-danger').click
    end
  end

  def when_i_click_the_all_reports_link
    click_link 'Reports'
  end

  def then_i_should_be_on_the_home_page
    expect(page).to have_css('table#protocols')
  end

  def then_i_should_see_the_participant_tracker_tab_is_active
    expect(page).to have_css('.nav-tabs a.active#participantTrackerTabLink')
  end

  def then_the_study_schedule_tab_should_be_active
    expect(page).to have_css('.nav-tabs a.active#studyScheduleTabLink')
  end

  def then_i_should_be_signed_out
    expect(page).to have_css('body.devise-sessions-new', visible: :all)
  end

  def then_i_should_be_on_the_reports_page
    expect(page).to have_css('body.documents-index', visible: :all)
  end

  alias_method :given_i_am_on_the_home_page, :when_i_visit_the_home_page
end
