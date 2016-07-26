require 'rails_helper'

feature 'Identity downloads a document from the documents page', js: true, enqueue: false do

  scenario 'and sees the viewed_at date has been updated' do
    given_i_am_viewing_the_all_reports_page_with_documents
    when_i_download_the_report
    then_i_should_see_the_viewed_at_date_has_been_updated
  end

  context 'with a single document' do
    scenario 'and sees the documents counter disappear' do
      given_i_am_viewing_the_all_reports_page_with_documents
      when_i_download_the_report
      then_i_should_not_see_the_documents_counter
    end
  end

  context 'with multiple documents' do
    scenario 'and sees the documents counter decrement' do
      given_i_am_viewing_the_all_reports_page_with_documents(2)
      when_i_download_the_report
      then_i_should_see_the_documents_counter_decrement_to(1)
    end
  end

  def given_i_am_viewing_the_all_reports_page_with_documents(count=1)
    @protocol = create_and_assign_protocol_to_me

    count.times do
      create(:document_of_identity_report, documentable_id: Identity.first.id)
    end

    visit documents_path
    wait_for_ajax
  end

  def when_i_download_the_report
    first("a.attached_file").trigger("click")
    wait_for_ajax
  end

  def then_i_should_not_see_the_documents_counter
    expect(page).to_not have_css(".identity_report_notifications")
  end

  def then_i_should_see_the_documents_counter_decrement_to(value)
    expect(page).to have_css(".identity_report_notifications", text: value)
  end

  def then_i_should_see_the_viewed_at_date_has_been_updated
    expect(page).to have_css("td.viewed_at", text: Time.now.strftime("%m/%d/%Y"))
  end
end
