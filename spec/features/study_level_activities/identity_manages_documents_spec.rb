require 'rails_helper'

feature 'Identity manages Doucuments', js: true do

  context 'User views line item documents' do
    scenario 'and sees the line item documents list' do
      given_i_am_viewing_the_study_level_activities_tab
      when_i_click_on_documents_icon('.documents[data-documentable-type="LineItem"]')
      then_i_should_see_the_line_item_documents_list
    end
  end

  context 'User uploads new line item document' do
    scenario 'and sees the document' do
      given_i_am_viewing_the_study_level_activities_tab
      when_i_have_a_document_to_upload
      when_i_click_on_documents_icon('.documents[data-documentable-type="LineItem"]')
      when_i_click_on_the_add_document_button
      when_i_upload_a_document
      when_i_click_on_documents_icon('.documents[data-documentable-type="LineItem"]')
      then_i_should_see_the_document
    end
  end


  context 'User views fulfillment documents' do
    scenario 'and sees the fulfillments documents list' do
      given_i_am_viewing_the_study_level_activities_tab
      when_i_open_up_a_fulfillment
      when_i_click_on_documents_icon('.documents[data-documentable-type="Fulfillment"]')
      then_i_should_see_the_fulfillment_documents_list
    end
  end

  context 'User uploads new fulfillment document' do
    scenario 'and sees the document' do
      given_i_am_viewing_the_study_level_activities_tab
      when_i_open_up_a_fulfillment
      when_i_click_on_documents_icon('.documents[data-documentable-type="Fulfillment"]')
      when_i_have_a_document_to_upload
      when_i_click_on_the_add_document_button
      when_i_upload_a_document
      when_i_click_on_documents_icon('.documents[data-documentable-type="Fulfillment"]')
      then_i_should_see_the_document
    end
  end

  def given_i_am_viewing_the_study_level_activities_tab
    protocol = create_and_assign_protocol_to_me

    visit protocol_path(protocol.id)
    click_link "Study Level Activities"
  end

  def when_i_click_on_documents_icon css_class
    first(css_class).click
    wait_for_ajax
  end

  def when_i_have_a_document_to_upload
    @filename = Rails.root.join('db', 'fixtures', 'test_document.txt')
  end

  def when_i_open_up_a_fulfillment
    first('.otf_fulfillments.list').click
  end

  def when_i_click_on_the_add_document_button
    find('.document.new').click
  end

  def when_i_upload_a_document
    wait_for_ajax
    attach_file(find("input[type='file']")[:id], @filename)
    click_button "Save"
  end

  def then_i_should_see_the_line_item_documents_list
    expect(page).to have_content('Line Item Documents')
  end

  def then_i_should_see_the_fulfillment_documents_list
    expect(page).to have_content('Fulfillment Documents')
  end

  def then_i_should_see_the_document
    expect(page).to have_content('test_document.txt')
  end
end
