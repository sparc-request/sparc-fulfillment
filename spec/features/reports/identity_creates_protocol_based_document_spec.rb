require 'rails_helper'

# For reports where:
# documentable_type = 'Protocol'
feature 'Identity creates a protocol-based Document', js: true, enqueue: false do

  scenario 'and sees the reports counter increment from zero to 1 to 2' do
    given_i_have_created_a_protocol_based_document
    then_i_should_see_the_counter_increment
    # request a second report
    given_i_have_created_a_second_protocol_based_document
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

  context 'and downloads the document' do
    scenario 'and sees the button default so that a new report can be run' do
      given_i_have_created_a_protocol_based_document
      when_i_click_the_created_document_icon
      when_i_click_the_download_option
      then_i_should_see_the_button_is_defaulted
    end

    scenario 'and sees the counter decrement/disappear' do
      given_i_have_created_a_protocol_based_document
      when_i_click_the_created_document_icon
      when_i_click_the_download_option
      then_i_should_see_the_counter_decrement_and_disappear
    end
  end

  scenario 'and generates a new document' do
    given_i_have_created_a_protocol_based_document
    when_i_click_the_created_document_icon
    when_i_click_the_generate_new_option
    then_i_should_see_a_new_document_generate
    and_i_should_be_able_to_interact_with_the_new_report
  end

  def given_i_have_created_a_protocol_based_document
    identity      = Identity.first
    @protocol     = create_and_assign_protocol_to_me
    @participant  = @protocol.participants.first

    visit protocol_path @protocol
    wait_for_ajax

    find('button.study_schedule_report').click
    wait_for_ajax

    @study_schedule_report_document_id = evaluate_script "$('button.study_schedule_report').data('document_id')"
  end

  def given_i_have_created_a_second_protocol_based_document
    visit protocol_path @protocol
    wait_for_ajax

    find("button#study_schedule_report_#{@protocol.id}").click
    wait_for_ajax

    @study_schedule_report_document_id = evaluate_script "$('button.study_schedule_report').data('document_id')"
  end

  def when_i_visit_the_reports_tab
    click_link 'Reports'
    wait_for_ajax
  end

  def when_i_click_the_created_document_icon
    find("button#study_schedule_report_#{@protocol.id}").trigger('click')
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

  def then_i_should_see_the_button_is_defaulted
    expect(page).to have_css("button.study_schedule_report.btn-default")
    expect(page).not_to have_css("button.study_schedule_report span.caret")
  end

  def then_i_should_see_the_counter_decrement_and_disappear
    expect(page).to have_no_css(".protocol_report_notifications", text: 0)
  end

  def then_i_should_see_a_new_document_generate
    expect(page).to have_css(".protocol_report_notifications", text: 2)

    click_link 'Reports'
    wait_for_ajax

    then_i_should_see_the_document
  end

  def and_i_should_be_able_to_interact_with_the_new_report
    click_link 'Participant Tracker'
    wait_for_ajax

    when_i_click_the_created_document_icon
    when_i_click_the_download_option

    expect(page).to have_css(".protocol_report_notifications", text: 1)
  end
end
