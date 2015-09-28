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
