require 'rails_helper'

feature 'Identity creates a document from the documents page', js: true do

  scenario 'of type Billing Report' do
    given_i_click_the_create_billing_report_button
    when_i_fill_in_the_report
    then_i_will_see_the_report_of_type 'Billing report'
    and_title_of 'Billing report'
  end

  scenario 'of type Auditing Report' do
    given_i_click_the_create_auditing_report_button
    when_i_fill_in_the_report
    then_i_will_see_the_report_of_type 'Auditing report'
    and_title_of 'Auditing report'
  end

  scenario 'of type Project Summary Report' do
    given_i_click_the_create_project_summary_report_button
    when_i_fill_in_the_report
    then_i_will_see_the_report_of_type 'Project summary report'
    and_title_of 'Project summary report'
  end

  def given_i_am_viewing_the_documents_page
    identity    = Identity.first
    @protocol    = create_and_assign_protocol_to_me

    visit documents_path
  end

  def given_i_click_the_create_billing_report_button
    given_i_am_viewing_the_documents_page
    #Click button
  end

  def given_i_click_the_create_auditing_report_button
    given_i_am_viewing_the_documents_page
    #Click button
  end
  
  def given_i_click_the_create_project_summary_report_button
    given_i_am_viewing_the_documents_page
    #Click button
  end

  def when_i_fill_in_the_report
    #Fill in start date
    #Fill in completed date
    #Fill in protocol
  end

  def then_i_will_see_the_report_of_type report_type
    expect(page).to have_css("")
    #Find report of report_type
  end

  def and_title_of title
    expect(page).to have_css("tr td.title", text: title)
    #Find report with title title
end
