require 'rails_helper'

# For reports where:
# documentable_type = 'Protocol'
feature 'Identity creates a protocol-based Document', js: true, enqueue: false do

  before :each do
    given_i_am_viewing_the_reports_tab
  end

  context 'of type Participant Report' do
    scenario 'and sees the report' do
      when_i_create_a_document_of_type 'participant_report'
      then_i_should_see_the_document
    end
  end

  context 'of type Study Schedule Report' do
    scenario 'and sees the report' do
      when_i_create_a_document_of_type 'study_schedule_report'
      then_i_should_see_the_document
    end
  end

  context 'with no documents present' do
    scenario 'and does not see the counter' do
      then_i_should_not_see_the_documents_counter
    end
  end

  context 'with documents present' do
    scenario 'and sees the reports counter increment' do
      when_i_create_a_document_of_type 'study_schedule_report'
      then_i_should_see_the_counter_increment_to(1)
      # request a second report
      when_i_create_a_document_of_type 'participant_report'
      then_i_should_see_the_counter_increment_to(2)
    end
  end

  scenario 'and opens the finished document dropdown menu' do
    when_i_create_a_document_of_type 'study_schedule_report'
    when_i_click_the_created_document_icon
    then_i_should_see_the_options_dropdown
  end

  context 'and downloads the document' do
    scenario 'and sees the button default so that a new report can be run' do
      when_i_create_a_document_of_type 'study_schedule_report'
      when_i_click_the_created_document_icon
      when_i_click_the_download_option
      then_i_should_see_the_button_is_defaulted
    end
  end

  scenario 'and generates a new document' do
    when_i_create_a_document_of_type 'study_schedule_report'
    when_i_click_the_created_document_icon
    when_i_click_the_generate_new_option
    then_i_should_see_the_document
  end

  def given_i_am_viewing_the_reports_tab
    @protocol = create_and_assign_protocol_to_me

    visit protocol_path @protocol
    wait_for_ajax

    click_link 'Reports'
    wait_for_ajax
  end

  def when_i_create_a_document_of_type(type)
    case type
    when 'study_schedule_report'
      find("button#study_schedule_report_#{@protocol.id.to_s}").click
      wait_for_ajax

      @document_id = find("button#study_schedule_report_#{@protocol.id.to_s}")["document_id"]
    when 'participant_report'
      click_link 'Participant Tracker'

      first("button.participant_report").click
      wait_for_ajax

      @document_id = first("button.participant_report")["document_id"]
    end
  end

  def when_i_click_the_created_document_icon
    find("button#study_schedule_report_#{@protocol.id.to_s}").trigger('click')
    wait_for_ajax
  end

  def when_i_click_the_download_option
    find("ul#document_menu_study_schedule_report_#{@protocol.id.to_s} li a[title='Download Report']").click
    wait_for_ajax
  end

  def when_i_click_the_generate_new_option
    find("ul#document_menu_study_schedule_report_#{@protocol.id.to_s} li a[title='Generate New Report']").click
    wait_for_ajax
  end

  def then_i_should_see_the_document
    click_link 'Reports'
    wait_for_ajax

    expect(page).to have_css("a#file_#{@document_id}")
  end

  def then_i_should_see_the_options_dropdown
    expect(page).to have_selector("ul#document_menu_study_schedule_report_#{@protocol.id.to_s}", visible: true)
  end

  def then_i_should_see_the_button_is_defaulted
    expect(page).to have_css("button.study_schedule_report.btn-default")
    expect(page).not_to have_css("button.study_schedule_report span.caret")
  end

  def then_i_should_not_see_the_documents_counter
    expect(page).to_not have_css(".protocol_report_notifications")
  end

  def then_i_should_see_the_counter_increment_to(value)
    expect(page).to have_css(".protocol_report_notifications", text: value)
  end
end
