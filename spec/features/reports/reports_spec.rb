require 'rails_helper'

feature 'Reports', js: true do

  before(:each) do
    @protocol = create_and_assign_protocol_to_me
    go_to_reports
  end

  scenario 'User clicks on Billing Report button' do
    when_i_click_the_new_report_button('billing')
    and_fill_in_the_new_billing_report_modal
    i_should_see_the_new_report_listed('Billing')
  end

  scenario 'User clicks on Auditing Report button' do
    when_i_click_the_new_report_button('auditing')
    and_fill_in_the_new_auditing_report_modal
    i_should_see_the_new_report_listed('Auditing')
  end

  scenario 'User clicks on Participant Report button' do
    when_i_click_the_new_report_button('participant')
    and_fill_in_the_new_participant_report_modal
    i_should_see_the_new_report_listed('Participant')
  end

  scenario 'User clicks on Project Summary Report button' do
    when_i_click_the_new_report_button('project_summary')
    and_fill_in_the_new_project_summary_report_modal
    i_should_see_the_new_report_listed('Project Summary')
  end

  def go_to_reports
    visit reports_path
  end

  def when_i_click_the_new_report_button(kind)
    find("#new_#{kind}_report").click
  end

  def and_fill_in_the_new_billing_report_modal
    fill_in 'Start Date', with: Date.today.strftime("%m-%d-%Y")
    fill_in 'End Date', with: Date.tomorrow.strftime("%m-%d-%Y")

    # close calendar thing, so it's not covering protocol dropdown
    first('.modal-header').click
    wait_for_ajax

    bootstrap_select '#protocol_ids', @protocol.short_title_with_sparc_id

    # close protocol dropdown, so it's not covering 'Request Report' button
    first('.modal-header').click
    wait_for_ajax
    find("input[value='Request Report']").click
  end

  def and_fill_in_the_new_project_summary_report_modal
    fill_in 'Start Date', with: Date.today.strftime("%m-%d-%Y")
    fill_in 'End Date', with: Date.tomorrow.strftime("%m-%d-%Y")
    first('.modal-header').click
    wait_for_ajax
    bootstrap_select '#protocol_id', @protocol.short_title_with_sparc_id
    first('.modal-header').click
    wait_for_ajax
    find("input[value='Request Report']").click
  end

  def and_fill_in_the_new_participant_report_modal
  end

  def i_should_see_the_new_report_listed(kind)
    expect(page).to have_css('#reports-list', text: "#{kind} Report")
  end

  alias :and_fill_in_the_new_auditing_report_modal :and_fill_in_the_new_billing_report_modal
end
