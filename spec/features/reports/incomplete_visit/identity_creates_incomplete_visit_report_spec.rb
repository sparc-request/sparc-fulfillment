require 'rails_helper'

feature 'Identity creates incomplete visit report', js: true do

  scenario 'with a start and end date' do
    given_i_am_requesting_an_incomplete_visit_report
    and_i_fill_in_valid_data
    when_i_request_the_report
    then_i_should_see_the_report_in_the_list_of_reports
  end

  def given_i_am_requesting_an_incomplete_visit_report
    create_and_assign_protocol_to_me
    visit documents_path
    wait_for_ajax
    click_button 'Incomplete Visit Report'
    wait_for_ajax
  end

  def and_i_fill_in_valid_data
    fill_in 'Title', with: 'Report title'
    fill_in 'Start Date', with: Time.current.strftime('%m-%d-%Y')
    fill_in 'Start Date', with: Time.current.strftime('%m-%d-%Y')
  end

  def when_i_request_the_report
    click_button 'Request Report'
  end

  def then_i_should_see_the_report_in_the_list_of_reports
    expect(page).to have_css('table.documents tbody tr td', text: 'Incomplete Visit Report')
  end
end
