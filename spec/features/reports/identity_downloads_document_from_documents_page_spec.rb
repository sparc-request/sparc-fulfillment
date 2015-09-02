require 'rails_helper'

feature 'Identity downloads a document from the documents page', js: true, enqueue: false do

  scenario 'and sees the documents counter decrement' do
    given_i_have_created_an_identity_based_report   
    when_i_download_the_report 
    then_i_should_see_the_documents_counter_decrement
  end

  scenario 'and sees the downloaded_at date has been updated' do
    given_i_have_created_an_identity_based_report
    when_i_download_the_report
    then_i_should_see_the_downloaded_at_date_has_been_updated
  end

  def given_i_click_the_create_report_button_of_type report_type
    @protocol = create_and_assign_protocol_to_me
    create(:participant, protocol: @protocol)

    visit documents_path
    
    find("[data-type='#{report_type}']").click
    wait_for_ajax
  end

  def when_i_fill_in_the_report_of_type report_type
    fill_in 'Start Date', with: Date.today.strftime("%m-%d-%Y")
    fill_in 'End Date', with: Date.tomorrow.strftime("%m-%d-%Y")

    # close calendar thing, so it's not covering protocol dropdown
    first('.modal-header').click
    wait_for_ajax

    bootstrap_select (report_type == 'project_summary_report' ? '#protocol_id' : '#protocol_ids'), @protocol.short_title_with_sparc_id

    # close protocol dropdown, so it's not covering 'Request Report' button
    first('.modal-header').click
    wait_for_ajax
    find("input[type='submit']").click
    wait_for_ajax
  end

  def given_i_have_created_an_identity_based_report
    given_i_click_the_create_report_button_of_type 'billing_report'
    when_i_fill_in_the_report_of_type 'billing_report'

    expect(page).to have_css(".identity_report_notifications", text: 1)
  end

  def when_i_download_the_report
    find("a.attached_file").trigger("click")
    wait_for_ajax
  end

  def then_i_should_see_the_documents_counter_decrement
    expect(page).to have_css(".identity_report_notifications", text: 0)
  end

  def then_i_should_see_the_downloaded_at_date_has_been_updated
    #Get formatter from en.yml -> documents -> date_time_formatter_ruby
    expect(page).to have_css("td.downloaded_at", text: Time.now.strftime("%m/%d/%Y"))
  end 
end
