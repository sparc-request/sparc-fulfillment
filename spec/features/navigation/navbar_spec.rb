require 'rails_helper'

feature 'Navigation', js: true do

  scenario 'User clicks on Home button' do
    given_i_am_viewing_a_protocol
    and_i_click_the_home_button
    then_i_should_be_on_the_home_page
  end

  scenario 'User returns to protocol page from Participant Tracker page' do
    given_i_am_on_the_participant_page
    and_i_click_the_browser_back_button
    then_i_should_see_the_participant_tracker_tab_is_active
  end

  scenario 'User switches between Protocols and views active tabs' do
    given_there_are_two_protocols
    and_i_view_the_first_protocol_participant_tracker
    and_i_visit_the_home_page
    and_i_view_the_second_protocol
    then_the_study_schedule_tab_should_be_active
  end

  scenario 'User clicks on the sign out click' do
    visit root_path
    accept_confirm do
      click_link 'sign-out-link'
    end
    page.has_css?('body.devise-sessions-new')
  end

  def given_there_are_two_protocols
    2.times { create_and_assign_protocol_to_me }
  end

  def and_i_view_the_first_protocol_participant_tracker
    protocol = Protocol.first

    visit protocol_path(protocol.sparc_id)
    click_link 'Participant Tracker'
  end

  def and_i_visit_the_home_page
    visit root_path
  end

  def and_i_view_the_second_protocol
    protocol = Protocol.second

    visit protocol_path(protocol.sparc_id)
  end

  def then_the_study_schedule_tab_should_be_active
    expect(page.body).to have_css('.tab-pane.active#study_schedule')
  end

  def given_i_am_viewing_a_protocol
    create_and_assign_protocol_to_me
    protocol = Protocol.first

    visit protocol_path(protocol.sparc_id)
  end

  def and_i_click_the_home_button
    click_link 'Home'
  end

  def then_i_should_be_on_the_home_page
    expect(page.body).to have_css('table.protocols')
  end

  def given_i_am_on_the_participant_page
    given_i_am_viewing_a_protocol
    click_link 'Participant Tracker'
    page.find('table.participants tbody tr:first-child td.calendar a').click
  end

  def and_i_click_the_browser_back_button
    click_browser_back_button
  end

  def then_i_should_see_the_participant_tracker_tab_is_active
    expect(page.body).to have_css('.tab-pane.active#participant_tracker')
  end
end
