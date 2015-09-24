require 'rails_helper'

# For reports where:
# documentable_type = 'Protocol'
feature 'Identity creates a protocol-based Document', js: true, enqueue: false do

  scenario 'and sees the reports counter increment from zero to 1 to 2' do
    given_i_have_created_a_protocol_based_document
    then_i_should_see_the_counter_increment
    # request a second report
    given_i_have_created_a_protocol_based_document
    then_i_should_see_the_counter_increment_to_two
  end

  scenario 'and sees the report has been created in the reports tab' do
    given_i_have_created_a_protocol_based_document
    when_i_visit_the_reports_tab
    then_i_should_see_the_document
  end

  scenario 'and opens the finished document dropdown menu' do
    given_i_have_created_a_protocol_based_document
    when_i_click_the_created_document_icon
    then_i_should_see_the_options_dropdown
  end

  scenario 'and downloads the document' do
    given_i_have_created_a_protocol_based_document
    when_i_click_the_created_document_icon
    when_i_click_the_download_option
    then_i_should_see_the_counter_decrement_and_disappear
  end

  scenario 'and generates a new document' do
    given_i_have_created_a_protocol_based_document
    when_i_click_the_created_document_icon
    when_i_click_the_generate_new_option
    then_i_should_see_a_new_document_generate
    and_i_should_be_able_to_interact_with_the_new_report
  end

  scenario 'with a custom title' do
    given_i_have_created_a_protocol_based_document
    when_i_visit_the_reports_tab
    when_i_edit_the_document_title
    then_i_should_see_the_documents_title_update  
  end

  def given_i_have_created_a_protocol_based_document
    identity    = Identity.first
    @protocol    = create_and_assign_protocol_to_me
    @participant = @protocol.participants.first

    visit protocol_path @protocol

    find("a#study_schedule_report_#{@protocol.id.to_s}").click
    wait_for_ajax

    @study_schedule_report_document_id = find("a#study_schedule_report_#{@protocol.id.to_s}")["document_id"]
  end

  def when_i_visit_the_reports_tab
    click_link 'Reports'
  end

  def when_i_click_the_created_document_icon
    find("a#study_schedule_report_#{@protocol.id.to_s}").trigger('click')
  end

  def when_i_click_the_download_option
    find("ul#document_menu_study_schedule_report_#{@protocol.id.to_s} li a[title='Download Report']").click
  end

  def when_i_click_the_generate_new_option
    find("ul#document_menu_study_schedule_report_#{@protocol.id.to_s} li a[title='Generate New Report']").click
  end

  def when_i_edit_the_document_title
    find("a.edit-document").click

    fill_in "Title", with: "Test Title"

    find("button[type='submit']").click
    wait_for_ajax
  end
    
  def then_i_should_see_the_counter_increment
    expect(page).to have_css(".protocol_report_notifications", text: 1)
  end
  
  def then_i_should_see_the_counter_increment_to_two
    expect(page).to have_css(".protocol_report_notifications", text: 2)
  end

  def then_i_should_see_the_document
    expect(page).to have_css("a#file_#{@study_schedule_report_document_id}")
  end

  def then_i_should_see_the_options_dropdown
    expect(page).to have_selector("ul#document_menu_study_schedule_report_#{@protocol.id.to_s}", visible: true)
  end

  def then_i_should_see_the_counter_decrement_and_disappear
    expect(page).to have_no_css(".protocol_report_notifications", text: 0)
  end

  def then_i_should_see_a_new_document_generate
    expect(page).to have_css(".protocol_report_notifications", text: 2)

    click_link 'Reports'

    then_i_should_see_the_document
  end

  def then_i_should_see_the_documents_title_update  
    expect(page).to have_css("td.title", text: "Test Title")
  end

  def and_i_should_be_able_to_interact_with_the_new_report
    click_link 'Participant Tracker'

    when_i_click_the_created_document_icon
    when_i_click_the_download_option

    expect(page).to have_css(".protocol_report_notifications", text: 1)
  end
end
