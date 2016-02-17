require 'rails_helper'

feature 'Identity edits document title', js: true, enqueue: false do

  context "User deletes a document" do
    context "from the All Reports page" do
      context "except they don't because the document is still processing" do
        scenario "and they see the delete icon is greyed out" do
          given_i_am_viewing_the_all_reports_page
          when_an_identity_document_is_not_completed
          then_i_should_see_the_delete_icon_is_greyed_out
        end
      end

      scenario "and does not see the report" do
        given_i_am_viewing_the_all_reports_page
        when_i_create_an_identity_based_document
        when_i_click_the_delete_icon
        then_i_should_not_see_the_document
      end

      context "which has not been accessed" do
        scenario "and sees the documents counter decrement" do
          given_i_am_viewing_the_all_reports_page
          when_i_create_an_identity_based_document
          when_i_create_an_identity_based_document
          when_i_click_the_delete_icon
          then_i_should_see_the_identity_docs_counter_was_decremented
        end
      end
    end

    context "from the Reports Tab" do
      context "except they don't because the document is still processing" do
        scenario "and they see the delete icon is greyed out" do
          given_i_am_viewing_the_reports_tab
          when_a_protocol_document_is_not_completed
          then_i_should_see_the_delete_icon_is_greyed_out
        end
      end

      scenario "and does not see the report" do
        given_i_am_viewing_the_reports_tab
        when_i_create_a_protocol_based_document
        when_i_click_the_delete_icon
        then_i_should_not_see_the_document
      end

      context "which has not been accessed" do
        scenario "and sees the documents counter decrement" do
          given_i_am_viewing_the_reports_tab
          when_i_create_a_protocol_based_document
          when_i_create_a_protocol_based_document
          when_i_click_the_delete_icon
          then_i_should_see_the_protocol_docs_counter_was_decremented
        end
      end
    end
  end


  def given_i_am_viewing_the_all_reports_page
    @protocol = create_and_assign_protocol_to_me
    create(:participant, protocol: @protocol)

    visit documents_path
    wait_for_ajax
  end

  def given_i_am_viewing_the_reports_tab
    identity    = Identity.first
    @protocol    = create_and_assign_protocol_to_me
    @participant = @protocol.participants.first

    visit protocol_path @protocol
    wait_for_ajax

    click_link 'Reports'
  end

  def when_i_create_an_identity_based_document
    find("[data-type='invoice_report']").click
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

  def when_an_identity_document_is_not_completed
    when_i_create_an_identity_based_document

    Document.first.update_attributes(state: "Processing")

    visit documents_path
    wait_for_ajax
  end

  def when_i_create_a_protocol_based_document
    create(:document_of_protocol_report, documentable_id: @protocol.id)
    visit protocol_path @protocol
    wait_for_ajax
  end

  def when_a_protocol_document_is_not_completed
    when_i_create_a_protocol_based_document

    Document.first.update_attributes(state: "Processing")

    visit protocol_path(@protocol)
    wait_for_ajax
  end

  def when_i_click_the_delete_icon
    first("a.remove-document").click
    wait_for_ajax
  end

  def then_i_should_see_the_delete_icon_is_greyed_out
    expect(page).to have_css("i.glyphicon-remove[style='cursor:default']")
  end

  def then_i_should_not_see_the_document
    expect(page).to_not have_css("a.attached_file")
  end

  def then_i_should_see_the_identity_docs_counter_was_decremented
    expect(page).to have_css(".identity_report_notifications", text: 1)
  end

  def then_i_should_see_the_protocol_docs_counter_was_decremented
    expect(page).to have_css(".protocol_report_notifications", text: 1)
  end
end