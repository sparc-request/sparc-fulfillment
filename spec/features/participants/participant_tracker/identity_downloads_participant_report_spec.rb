require 'rails_helper'

feature 'Identity downloads Participant Report', js: true do

  scenario 'and sees the participant report on the All Reports page' do
    given_i_have_requested_a_participant_report
    when_i_visit_the_reports_page
    then_i_should_see_the_participant_report_in_the_list_of_reports
  end

  scenario 'and sees the unread Documents counter decremented' do
    given_i_have_requested_a_participant_report
    when_i_download_the_report
    then_i_should_see_that_i_have_no_unaccessed_documents
  end

  def given_i_have_requested_a_participant_report
    protocol = create_and_assign_protocol_to_me

    visit protocol_path(protocol)
    click_link 'Participant Tracker'
    first('table.participants tbody td.participant_report a').click
  end

  def when_i_download_the_report
    first('table.participants tbody td.participant_report a').click
  end

  def when_i_visit_the_reports_page
    visit documents_path
  end

  def then_i_should_see_that_i_have_no_unaccessed_documents
    expect(page).to have_css('.notification.document-notifications', text: '0')
  end

  def then_i_should_see_the_participant_report_in_the_list_of_reports
    expect(page).to have_css('table.documents tbody td.title', count: 1)
  end
end
