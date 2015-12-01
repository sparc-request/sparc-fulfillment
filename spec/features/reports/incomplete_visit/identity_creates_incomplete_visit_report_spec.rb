require 'rails_helper'

feature 'Identity creates incomplete visit report', js: true do

  scenario 'and sees a default start date' do
    given_i_am_requesting_an_incomplete_visit_report
    when_i_click_the_incomplete_visit_report_button
    then_i_should_see_a_default_start_date
  end

  scenario 'with a start and end date' do
    given_i_am_requesting_an_incomplete_visit_report
    when_i_click_the_incomplete_visit_report_button
      and_i_fill_in_valid_data
      and_i_request_the_report
    then_i_should_see_the_report_in_the_list_of_reports
  end

  def given_i_am_requesting_an_incomplete_visit_report
    create_and_assign_protocol_to_me
    visit documents_path
    wait_for_ajax
  end

  def and_i_fill_in_valid_data
    fill_in 'report_title', with: 'Report title'
    fill_in 'report_start_date', with: Time.current.strftime('%m-%d-%Y')
    fill_in 'report_end_date', with: Time.current.strftime('%m-%d-%Y')
  end

  def and_i_request_the_report
    click_button 'Request Report'
  end

  def when_i_click_the_incomplete_visit_report_button
    click_button 'Incomplete Visit Report'
    wait_for_ajax
  end

  def then_i_should_see_the_report_in_the_list_of_reports
    expect(page).to have_css('table.documents tbody td.title', text: 'Report title')
  end

  def then_i_should_see_a_default_start_date
    expect(page).to have_selector("input#report_start_date[value='11-25-2015']")
  end
end
