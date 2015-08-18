require 'rails_helper'

feature 'Notes', js: true do

  context 'User views line item notes' do
    scenario 'and sees the line item notes list' do
      given_i_am_viewing_the_study_level_activities_tab
      when_i_click_on_notes_icon('.notes.list[data-notable-type="LineItem"]')
      then_i_should_see_the_line_item_notes_list
    end
  end

  context 'User creates line item note' do
    scenario 'and sees the note in the line items notes list' do
      given_i_am_viewing_the_study_level_activities_tab
      when_i_click_on_notes_icon('.notes.list[data-notable-type="LineItem"]')
      when_i_click_on_the_add_note_button
      when_i_fill_out_and_save_the_note
      when_i_click_on_notes_icon('.notes.list[data-notable-type="LineItem"]')
      then_i_should_see_the_note
    end
  end

  context 'User views fulfillment notes' do
    scenario 'and sees the fulfillments notes list' do
      given_i_am_viewing_the_study_level_activities_tab
      when_i_open_up_a_fulfillment
      when_i_click_on_notes_icon('.notes.list[data-notable-type="Fulfillment"]')
      then_i_should_see_the_fulfillment_notes_list
    end
  end

  context 'User creates fulfillment note' do
    scenario 'and sees the note in the fulfillments notes list' do
      given_i_am_viewing_the_study_level_activities_tab
      when_i_open_up_a_fulfillment
      when_i_click_on_notes_icon('.notes.list[data-notable-type="Fulfillment"]')
      when_i_click_on_the_add_note_button
      when_i_fill_out_and_save_the_note
      when_i_click_on_notes_icon('.notes.list[data-notable-type="Fulfillment"]')
      then_i_should_see_the_note
    end
  end

  def given_i_am_viewing_the_study_level_activities_tab
    protocol = create_and_assign_protocol_to_me

    visit protocol_path(protocol.id)
    click_link "Study Level Activities"
  end

  def when_i_open_up_a_fulfillment
    first('.otf_fulfillments.list').click
  end
  
  def when_i_click_on_notes_icon css_class
    first(css_class).click
    wait_for_ajax
  end
  
  def when_i_click_on_the_add_note_button
    find('.note.new').click
  end

  def when_i_fill_out_and_save_the_note
    wait_for_ajax
    fill_in 'note_comment', with: "Test Comment"
    wait_for_ajax
    click_button 'Save'
  end

  def then_i_should_see_the_line_item_notes_list
    expect(page).to have_content('Line Item Notes')
  end

  def then_i_should_see_the_note
    expect(page).to have_content("Test Comment")
  end

  def then_i_should_see_the_fulfillment_notes_list
    expect(page).to have_content('Fulfillment Notes')
  end
end
