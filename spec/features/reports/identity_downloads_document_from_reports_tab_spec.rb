require 'rails_helper'

feature 'Identity downloads a document from the reports tab', js: true, enqueue: false do

  scenario 'and sees the reports counter decrement' do
    given_i_have_a_report_and_visit_the_reports_tab
    when_i_download_the_report
    then_i_should_see_the_reports_counter_at_zero
  end

  scenario 'and sees the downloaded_at date has been updated' do
    given_i_have_a_report_and_visit_the_reports_tab
    when_i_download_the_report
    then_i_should_see_the_downloaded_at_date_has_been_updated
  end

  def given_i_have_a_report_and_visit_the_reports_tab
    identity    = Identity.first
    @protocol    = create_and_assign_protocol_to_me
    @participant = @protocol.participants.first
    @document = create(:document_with_csv_file, documentable_id: @protocol.id, documentable_type: "Protocol", report_type: "study_schedule_report", state: "Completed")
    visit protocol_path @protocol
    click_link 'Reports'
  end

  def when_i_download_the_report
    click_link "file_#{@document.id}"
    wait_for_ajax
  end

  def then_i_should_see_the_reports_counter_at_zero
    wait_for_ajax
    expect(page).to have_css(".protocol_report_notifications", text: 0)
  end

  def then_i_should_see_the_downloaded_at_date_has_been_updated
    #Get formatter from en.yml -> documents -> date_time_formatter_ruby
    expect(page).to have_css("td.downloaded_at", text: Time.now.strftime("%m/%d/%Y"))
  end
end
