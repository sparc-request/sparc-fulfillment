require 'rails_helper'

feature 'Identity edits document title', js: true, enqueue: false do

  context "User edits a document's title" do
    context "when creating a report" do
      scenario "and sees the custom title" do
        given_i_am_viewing_the_all_reports_page
        when_i_create_an_identity_based_document_with_a_custom_title
        then_i_should_see_the_title_has_been_updated
      end
    end
    
    context "from the All Reports page" do
      scenario "and sees the title has changed" do
        given_i_am_viewing_the_all_reports_page
        when_i_create_an_identity_based_document
        when_i_edit_the_title
        then_i_should_see_the_title_has_been_updated
      end
    end

    context "from the Reports Tab" do
      scenario "and sees the title has changed" do
        given_i_am_viewing_the_reports_tab
        when_i_create_a_protocol_based_document
        when_i_edit_the_title
        then_i_should_see_the_title_has_been_updated
      end
    end
  end

  def given_i_am_viewing_the_all_reports_page
    @protocol = create_and_assign_protocol_to_me
    create(:participant, protocol: @protocol)

    visit documents_path
  end

  def given_i_am_viewing_the_reports_tab
    identity    = Identity.first
    @protocol    = create_and_assign_protocol_to_me
    @participant = @protocol.participants.first

    visit protocol_path @protocol
    wait_for_ajax

    click_link 'Reports'
  end

  def when_i_create_an_identity_based_document_with_a_custom_title
    find("[data-type='billing_report']").click
    wait_for_ajax

    fill_in 'Title', with: "A custom title"
    fill_in 'Start Date', with: Date.today.strftime("%m-%d-%Y")
    fill_in 'End Date', with: Date.tomorrow.strftime("%m-%d-%Y")

    # close calendar thing, so it's not covering protocol dropdown
    first('.modal-header').click
    wait_for_ajax

    bootstrap_select '#protocol_ids', @protocol.short_title_with_sparc_id

    # close protocol dropdown, so it's not covering 'Request Report' button
    first('.modal-header').click
    wait_for_ajax
    find("input[type='submit']").click
    wait_for_ajax
  end

  def when_i_create_an_identity_based_document
    find("[data-type='billing_report']").click
    wait_for_ajax

    fill_in 'Start Date', with: Date.today.strftime("%m-%d-%Y")
    fill_in 'End Date', with: Date.tomorrow.strftime("%m-%d-%Y")

    # close calendar thing, so it's not covering protocol dropdown
    first('.modal-header').click
    wait_for_ajax 

    bootstrap_select ('#protocol_ids'), @protocol.short_title_with_sparc_id

    # close protocol dropdown, so it's not covering 'Request Report' button
    first('.modal-header').click
    wait_for_ajax
    find("input[type='submit']").click
    wait_for_ajax
  end

  def when_i_create_a_protocol_based_document
    find("button#study_schedule_report_#{@protocol.id.to_s}").click
    wait_for_ajax
  end

  def when_i_edit_the_title
    first("a.edit-document").click
    wait_for_ajax

    fill_in 'Title', with: "A custom title"

    find("button[type='submit']").click
    wait_for_ajax
  end

  def then_i_should_see_the_title_has_been_updated
    expect(page).to have_css('table tbody tr td', text: "A custom title")
  end
end