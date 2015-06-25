require 'rails_helper'

feature 'Identity downloads Study Schedule Report', js: true do

  scenario 'and sees the Documents notification decrement' do
    given_i_am_viewing_a_protocol
    when_i_download_the_study_schedule_report
    then_i_should_see_the_documents_notification_decrement
  end

  scenario 'and sees the Document on the Reports page' do
    given_i_have_created_a_study_schedule_report
    when_i_visit_the_reports_page
    then_it_should_see_the_study_schedule_report_in_the_list_of_reports
  end

  def given_i_have_created_a_study_schedule_report
    given_i_am_viewing_a_protocol
    when_i_download_the_study_schedule_report
  end

  def given_i_am_viewing_a_protocol
    protocol = create_and_assign_protocol_to_me

    visit protocol_path(protocol)
  end

  def when_i_visit_the_reports_page
    visit documents_path
  end

  def when_i_download_the_study_schedule_report
    find('a.study_schedule_report').click
    wait_for_ajax
  end

  def then_it_should_see_the_study_schedule_report_in_the_list_of_reports
    expect(page).to have_css('table.documents tbody td.title', count: 1)
  end

  def then_i_should_see_the_documents_notification_decrement
    expect(page).to have_css('.notification.document-notifications', text: '0')
  end
end
