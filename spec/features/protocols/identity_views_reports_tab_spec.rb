require 'rails_helper'

feature 'Identity views Report tab', js: true, enqueue: false do

  scenario 'and sees a list of Protocol reports' do
    given_i_have_created_a_study_schedule_report
    when_i_view_the_reports_tab
    then_i_should_see_a_report_in_the_protocol_reports_table
  end

  scenario 'and sees a list of Participant reports' do
    given_i_have_created_a_participant_report
    when_i_view_the_reports_tab
    then_i_should_see_a_report_in_the_participant_reports_table
  end

  def given_i_have_created_a_study_schedule_report
    protocol = create_and_assign_protocol_to_me

    visit protocol_path protocol
    
    create(:document_of_protocol_report, documentable_id: protocol.id)
  end

  def given_i_have_created_a_participant_report
    protocol = create_and_assign_protocol_to_me
    participant = protocol.participants.first

    visit protocol_path protocol

    create(:document_of_participant_report, documentable_id: protocol.id)
  end

  def when_i_view_the_reports_tab
    click_link 'Reports'
  end

  def then_i_should_see_a_report_in_the_protocol_reports_table
    expect(page).to have_css('table.protocol_reports tbody td.title', count: 1)
  end

  def then_i_should_see_a_report_in_the_participant_reports_table
    expect(page).to have_css('table.protocol_reports tbody td.title', count: 1)
  end
end
