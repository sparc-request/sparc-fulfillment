require 'rails_helper'

feature 'Identity requests report', js: true do

  before(:each) do
    @protocol = create_and_assign_protocol_to_me
    create(:participant, protocol: @protocol)

    visit documents_path
  end

  scenario 'Identity clicks on Billing Report button' do
    when_i_click_the_new_report_button('billing_report')
    and_fill_in_the_new_billing_report_modal
    i_should_see_the_new_report_listed('Billing')
  end

  scenario 'Identity clicks on Auditing Report button' do
    when_i_click_the_new_report_button('auditing_report')
    and_fill_in_the_new_auditing_report_modal
    i_should_see_the_new_report_listed('Auditing')
  end

  scenario 'Identity clicks on Project Summary Report button' do
    when_i_click_the_new_report_button('project_summary_report')
    and_fill_in_the_new_project_summary_report_modal
    i_should_see_the_new_report_listed('Project summary')
  end

  scenario 'Sees the the unread documents counter increment' do
    when_i_click_the_new_report_button('billing_report')
    and_fill_in_the_new_billing_report_modal
    i_should_see_the_unaccessed_documents_counter_increment
  end

  scenario 'Sees protocols assigned to user' do
    when_i_click_the_new_report_button('billing_report')
    and_open_the_protocol_dropdown
    i_should_see_protocols_assigned_to_me
  end

  scenario 'Does not see protocols not assigned to user' do
    ClinicalProvider.destroy_all
    when_i_click_the_new_report_button('billing_report')
    and_open_the_protocol_dropdown
    i_should_not_see_any_protocols
  end

  def when_i_click_the_new_report_button(kind)
    find("[data-title='#{kind}']").click
    wait_for_ajax
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
    find("button.submit").click
    wait_for_ajax
  end

  def and_fill_in_the_new_project_summary_report_modal
    fill_in 'Start Date', with: Date.today.strftime("%m-%d-%Y")
    fill_in 'End Date', with: Date.tomorrow.strftime("%m-%d-%Y")
    first('.modal-header').click
    wait_for_ajax
    bootstrap_select '#protocol_id', @protocol.short_title_with_sparc_id
    first('.modal-header').click
    wait_for_ajax
    find("button.submit").click
  end

  def and_fill_in_the_new_participant_report_modal
    bootstrap_select '#participant_id', Participant.first.full_name_with_label
    first('.modal-header').click
    wait_for_ajax
    find("button.submit").click
  end

  def and_open_the_protocol_dropdown
    first('.dropdown-toggle.selectpicker').click
    wait_for_ajax
  end

  def i_should_see_the_new_report_listed(kind)
    expect(page).to have_css('table.documents tbody tr', text: "#{kind} report")
  end

  def i_should_see_the_unaccessed_documents_counter_increment
    expect(page).to have_css(".notification.document-notifications", text: 1)
  end

  def i_should_see_protocols_assigned_to_me
    expect(page).to have_css("ul.dropdown-menu.inner.selectpicker li")
  end

  def i_should_not_see_any_protocols
    expect(page).to_not have_css("ul.dropdown-menu.inner.selectpicker li")
  end

  alias :and_fill_in_the_new_auditing_report_modal :and_fill_in_the_new_billing_report_modal
end
