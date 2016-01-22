require 'rails_helper'

# For reports where:
# documentable_type = 'Identity'
feature 'Identity creates a document from the documents page', js: true do

  before :each do
    given_i_am_viewing_the_documents_index_page
  end

  context 'of type Billing Report' do
    scenario 'and sees the report' do
      given_i_click_the_create_report_button_of_type 'billing_report'
      when_i_fill_in_the_report_of_type 'billing_report'
      then_i_will_see_the_new_report_listed 'Billing report'
    end
  end

  context 'of type Auditing Report' do
    scenario 'and sees the report' do
      given_i_click_the_create_report_button_of_type 'auditing_report'
      when_i_fill_in_the_report_of_type 'auditing_report'
      then_i_will_see_the_new_report_listed 'Auditing report'
    end
  end

  context 'of type Incomplete Visit Report' do
    scenario 'and sees the report' do
      given_i_click_the_create_report_button_of_type 'incomplete_visit_report'
      when_i_fill_in_the_report_of_type 'incomplete_visit_report'
      then_i_will_see_the_new_report_listed 'Incomplete visit report'
    end
  end

  context 'of type Project Summary Report' do
    scenario 'and sees the report' do
      given_i_click_the_create_report_button_of_type 'project_summary_report'
      when_i_fill_in_the_report_of_type 'project_summary_report'
      then_i_will_see_the_new_report_listed 'Project summary report'
    end
  end

  scenario 'and sees the documents counter increment' do
    given_i_click_the_create_report_button_of_type 'billing_report'
    when_i_fill_in_the_report_of_type 'auditing_report'
    then_i_should_see_the_documents_counter_increment
    # submit a request for a second report
    given_i_click_the_create_report_button_of_type 'project_summary_report'
    when_i_fill_in_the_report_of_type 'project_summary_report'
    then_i_should_see_the_documents_counter_increment_to_two
  end

  scenario 'and sees protocols assigned to the them' do
    given_i_click_the_create_report_button_of_type 'billing_report'
    when_i_open_the_protocol_dropdown
    then_i_should_see_protocols_assigned_to_me
  end

  scenario 'and does not see protocols not assigned to them' do
    ClinicalProvider.destroy_all
    given_i_click_the_create_report_button_of_type 'billing_report'
    when_i_open_the_protocol_dropdown
    then_i_should_not_see_protocols_not_assigned_to_me
  end

  #Must keep separated or else ClinicalProvider.destroy_all will not work
  def given_i_am_viewing_the_documents_index_page
    @protocol = create_and_assign_protocol_to_me
    create(:participant, protocol: @protocol)

    visit documents_path
    wait_for_ajax
  end

  def given_i_click_the_create_report_button_of_type(report_type)
    find("[data-kind='#{report_type}']").click
    wait_for_ajax
  end

  def when_i_fill_in_the_report_of_type(report_type)
    fill_in 'Title', with: 'Title'
    fill_in 'Start Date', with: Date.today.strftime("%m-%d-%Y")
    fill_in 'End Date', with: Date.tomorrow.strftime("%m-%d-%Y")

    # close calendar thing, so it's not covering protocol dropdown
    first('.modal-header').click
    wait_for_ajax

    unless report_type == 'incomplete_visit_report'
      bootstrap_select (report_type == 'project_summary_report' ? '#report_protocol_id' : '#report_protocol_ids'), @protocol.short_title_with_sparc_id

      # close protocol dropdown, so it's not covering 'Request Report' button
      first('.modal-header').click
      wait_for_ajax
    end

    click_button 'Request Report'
    wait_for_ajax
  end

  def when_i_open_the_protocol_dropdown
    first('.dropdown-toggle.selectpicker').click
    wait_for_ajax
  end

  def then_i_will_see_the_new_report_listed report_type
    expect(page).to have_css('table.documents tbody tr td.title', text: 'Title')
  end

  def then_i_should_see_the_documents_counter_increment
    expect(page).to have_css(".notification.identity_report_notifications", text: 1)
  end

  def then_i_should_see_the_documents_counter_increment_to_two
    expect(page).to have_css(".notification.identity_report_notifications", text: 2)
  end

  def then_i_should_see_protocols_assigned_to_me
    expect(page).to have_css("ul.dropdown-menu.inner.selectpicker li")
  end

  def then_i_should_not_see_protocols_not_assigned_to_me
    expect(page).to_not have_css("ul.dropdown-menu.inner.selectpicker li")
  end
end
