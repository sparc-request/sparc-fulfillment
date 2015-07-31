require 'rails_helper'

feature 'Identity downloads a document from the reports tab', js: true, enqueue: false do

  before :each do
    given_i_am_viewing_the_protocol_show_page
  end

  scenario 'and sees the reports counter decrement' do
    given_i_have_created_a_protocol_based_report
    when_i_visit_the_reports_tab
    when_i_download_the_report
    then_i_should_see_the_reports_counter_decrement
  end

  scenario 'and sees the downloaded_at date has been updated' do
    given_i_have_created_a_protocol_based_report
    when_i_visit_the_reports_tab
    when_i_download_the_report
    then_i_should_see_the_downloaded_at_date_has_been_updated
  end

  def given_i_am_viewing_the_protocol_show_page
    identity    = Identity.first
    @protocol    = create_and_assign_protocol_to_me
    @participant = @protocol.participants.first

    visit protocol_path @protocol
  end

  def given_i_have_created_a_protocol_based_report
    find("a#study_schedule_report_#{@protocol.id.to_s}").click
    wait_for_ajax

    @study_schedule_report_document_id = find("a#study_schedule_report_#{@protocol.id.to_s}")["document_id"]

    expect(page).to have_css(".report-notifications", text: 1)
  end

  def when_i_visit_the_reports_tab
    click_link 'Reports'
  end

  def when_i_download_the_report
    find("a#file_#{@study_schedule_report_document_id}").trigger("click")
    wait_for_ajax
  end

  def then_i_should_see_the_reports_counter_decrement
    expect(page).to have_css(".report-notifications", text: 0)
  end

  def then_i_should_see_the_downloaded_at_date_has_been_updated
    #Get formatter from en.yml -> documents -> date_time_formatter_ruby
    expect(page).to have_css("td.downloaded_at", text: Time.now.strftime("%m/%d/%Y"))
  end
end
