require 'rails_helper'

feature 'Identity downloads Study Schedule Report', js: true do

  scenario 'and sees the Documents notification decrement' do
    given_i_am_viewing_a_protocol
    when_i_download_the_study_schedule_report
    then_i_should_see_the_documents_notification_decrement
  end

  def given_i_am_viewing_a_protocol
    protocol = create_and_assign_protocol_to_me

    visit protocol_path(protocol)
  end

  def when_i_download_the_study_schedule_report
    find('a.study_schedule_report').click
  end

  def then_i_should_see_the_documents_notification_decrement
    expect(page).to have_css('.notification.document-notifications', text: '0')
  end
end
