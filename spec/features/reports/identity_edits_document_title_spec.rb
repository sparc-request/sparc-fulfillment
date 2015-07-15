require 'rails_helper'

feature 'Identity edits document title', js: true do

  before(:each) do
    @protocol = create_and_assign_protocol_to_me
    @document = create(:document_with_csv_file, documentable_type: "Identity", documentable_id: Identity.first.id)
    visit documents_path
  end

  scenario 'Identity changes the title of the report' do
    identity_clicks_on_report_edit_button
    identity_fills_in_new_title
    and_then_the_report_name_will_show_up_as_changed
  end

   def identity_clicks_on_report_edit_button
    find(".edit-document").click
   end

   def identity_fills_in_new_title
    fill_in "document[title]", with: "test title"
    click_button "Save"
   end

   def and_then_the_report_name_will_show_up_as_changed
    wait_for_ajax
    expect(page).to have_content "test title"
   end

 end
