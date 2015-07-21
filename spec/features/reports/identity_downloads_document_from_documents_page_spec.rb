require 'rails_helper'

feature 'Identity downloads a document from the documents page', js: true do

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

  def given_i_have_created_an_identity_based_report
    identity    = Identity.first
    @protocol    = create_and_assign_protocol_to_me

    visit documents_path

    #Click and fill out billing report button
    #Click and fill out auditing report button
    #Click and fill out project summary report button
    wait_for_ajax

    expect(page).to have_css(".document-notifications", text: 3)
  end

  def when_i_download_the_report 
    find('table.documents a.attached_file').click
  end

  def then_i_should_see_the_documents_counter_decrement
    expect(page).to have_css(".document-notifications", text: 0)
  end

  def then_i_should_see_the_downloaded_at_date_has_been_updated
    expect(page).to have_css("td.downloaded_at", text: Time.now.strftime("%m/%d/%Y"))
  end 
end
