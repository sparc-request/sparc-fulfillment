require 'rails_helper'

feature 'Identity deletes a document', js: true, enqueue: false do

  context "from the All Reports page" do
    context "except they don't because the document is still processing" do
      scenario "and they see the delete icon is greyed out" do
        given_i_am_viewing_the_all_reports_page_with_documents(1, "Processing")
        then_i_should_see_the_delete_icon_is_greyed_out
      end
    end

    scenario "and does not see the report" do
      given_i_am_viewing_the_all_reports_page_with_documents(1)
      when_i_click_the_delete_icon
      then_i_should_not_see_the_document
    end

    context "which has not been accessed" do
      scenario "and sees the documents counter decrement" do
        given_i_am_viewing_the_all_reports_page_with_documents(2)
        when_i_click_the_delete_icon
        then_i_should_see_the_identity_docs_counter_was_decremented
      end
    end
  end

  context "from the Reports Tab" do
    context "except they don't because the document is still processing" do
      scenario "and they see the delete icon is greyed out" do
        given_i_am_viewing_the_reports_tab_with_documents(1, "Processing")
        then_i_should_see_the_delete_icon_is_greyed_out
      end
    end

    scenario "and does not see the report" do
      given_i_am_viewing_the_reports_tab_with_documents(1)
      when_i_click_the_delete_icon
      then_i_should_not_see_the_document
    end

    context "which has not been accessed" do
      scenario "and sees the documents counter decrement" do
        given_i_am_viewing_the_reports_tab_with_documents(2)
        when_i_click_the_delete_icon
        then_i_should_see_the_protocol_docs_counter_was_decremented
      end
    end
  end

  def given_i_am_viewing_the_all_reports_page_with_documents(count, state="Completed")
    @protocol = create_and_assign_protocol_to_me

    count.times do
      create(:document_of_identity_report, documentable_id: Identity.first.id, state: state)
    end

    visit documents_path
    wait_for_ajax
  end

  def given_i_am_viewing_the_reports_tab_with_documents(count, state="Completed")
    @protocol = create_and_assign_protocol_to_me

    count.times do
      create(:document_of_protocol_report, documentable_id: @protocol.id, state: state)
    end

    visit protocol_path @protocol
    wait_for_ajax

    click_link 'Reports'
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