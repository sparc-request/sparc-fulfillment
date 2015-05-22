require 'rails_helper'

feature 'Documents', js: true do

  scenario 'User views line item documents' do
    as_a_user_who_visits_study_level_activities_tab
    when_i_click_on_documents_icon('.documents[data-documentable-type="LineItem"]')
    then_i_should_see_the_line_item_documents_list
  end

  scenario 'User uploads new line item document' do
    as_a_user_who_visits_study_level_activities_tab
    if_i_have_a_document_to_upload
    when_i_click_on_documents_icon('.documents[data-documentable-type="LineItem"]')
    then_click_on_the_add_document_button
    then_i_upload_a_document
    when_i_click_on_documents_icon('.documents[data-documentable-type="LineItem"]')
    i_should_see_the_document
  end


  scenario 'User views fulfillment documents' do
    as_a_user_who_visits_study_level_activities_tab
    when_i_open_up_a_fulfillment
    when_i_click_on_documents_icon('.documents[data-documentable-type="Fulfillment"]')
    then_i_should_see_the_fulfillment_documents_list
  end

  scenario 'User uploads new fulfillment document' do
    as_a_user_who_visits_study_level_activities_tab
    when_i_open_up_a_fulfillment
    when_i_click_on_documents_icon('.documents[data-documentable-type="Fulfillment"]')
    if_i_have_a_document_to_upload
    then_click_on_the_add_document_button
    then_i_upload_a_document
    when_i_click_on_documents_icon('.documents[data-documentable-type="Fulfillment"]')
    i_should_see_the_document
  end

  def as_a_user_who_visits_study_level_activities_tab
    protocol = create(:protocol_imported_from_sparc)

    visit protocol_path(protocol.sparc_id)
    click_link "Study Level Activities"
  end

  def when_i_click_on_documents_icon css_class
    first(css_class).click
    wait_for_ajax
  end

  def then_i_should_see_the_line_item_documents_list 
    expect(page).to have_content('Line Item Documents')
  end

  def then_i_should_see_the_fulfillment_documents_list 
    expect(page).to have_content('Fulfillment Documents')
  end

  def if_i_have_a_document_to_upload
    @filename = Rails.root.join('spec', 'support', 'text_document.txt')
  end

  def then_click_on_the_add_document_button
    find('.document.new').click
  end

  def then_i_upload_a_document
    wait_for_ajax
    attach_file(find("input[type='file']")[:id], @filename)
    click_button "Save"
  end

  def i_should_see_the_document
    expect(page).to have_content('text_document.txt')
  end

  def when_i_open_up_a_fulfillment
    first('.otf_fulfillments.list').click
  end

end