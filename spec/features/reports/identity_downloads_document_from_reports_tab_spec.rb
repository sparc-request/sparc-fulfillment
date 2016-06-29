require 'rails_helper'

feature 'Identity downloads a document from the reports tab', js: true, enqueue: false do

  scenario 'and sees the viewed_at date has been updated' do
    given_i_am_viewing_the_reports_tab_with_documents
    when_i_download_the_report
    then_i_should_see_the_viewed_at_date_has_been_updated
  end

  context 'with a single document' do
    scenario 'and sees the documents counter disappear' do
      given_i_am_viewing_the_reports_tab_with_documents
      when_i_download_the_report
      then_i_should_not_see_the_reports_counter
    end
  end

  context 'with multiple documents' do
    scenario 'and sees the documents counter decrement' do
      given_i_am_viewing_the_reports_tab_with_documents(2)
      when_i_download_the_report
      then_i_should_see_the_reports_counter_decrement_to(1)
    end
  end

  def given_i_am_viewing_the_reports_tab_with_documents(count=1)
    @protocol = create_and_assign_protocol_to_me

    count.times do
      create(:document_of_protocol_report, documentable_id: @protocol.id)
    end

    @document = Document.first

    visit protocol_path @protocol
    wait_for_ajax

    click_link 'Reports'
    wait_for_ajax
  end

  def when_i_download_the_report
    click_link "file_#{@document.id}"
    wait_for_ajax
  end

  def then_i_should_not_see_the_reports_counter
    expect(page).to_not have_css(".protocol_report_notifications")
  end

  def then_i_should_see_the_reports_counter_decrement_to(value)
    expect(page).to have_css(".protocol_report_notifications", text: value)
  end

  def then_i_should_see_the_viewed_at_date_has_been_updated
    expect(page).to have_css("td.viewed_at", text: Time.now.strftime("%m/%d/%Y"))
  end
end
