require 'rails_helper'

feature 'Notes', js: true do

  scenario 'User views line item notes' do
    as_a_user_who_visits_study_level_activities_tab
    when_i_click_on_line_item_notes_icon
    then_i_should_see_the_line_item_notes_list
  end

  scenario 'User creates line item note' do
    as_a_user_who_visits_study_level_activities_tab
    when_i_click_on_line_item_notes_icon
    then_click_on_the_add_note_button
    then_i_fill_out_and_save_the_note
    when_i_click_on_line_item_notes_icon
    i_should_see_the_note
  end

  scenario 'User views fulfillment notes' do
    as_a_user_who_visits_study_level_activities_tab
    when_i_open_up_a_fulfillment
    when_i_click_on_fulfillment_notes_icon
    then_i_should_see_the_fulfillment_notes_list
  end

  scenario 'User creates fulfillment note' do
    as_a_user_who_visits_study_level_activities_tab
    when_i_open_up_a_fulfillment
    when_i_click_on_notes_icon
    then_click_on_the_add_note_button
    then_i_fill_out_and_save_the_note
    when_i_click_on_fulfillment_notes_icon
    i_should_see_the_note
  end

  def as_a_user_who_visits_study_level_activities_tab
    protocol = create(:protocol_imported_from_sparc)

    visit protocol_path(protocol.sparc_id)
    click_link "Study Level Activities"
  end

  def when_i_click_on_line_item_notes_icon
    first('.otf_notes').click
  end

  def then_i_should_see_the_line_item_notes_list
    expect(page).to have_content('Line Item Notes')
  end

  def then_click_on_the_add_note_button
    find('.note.line_item.new').click
  end

  def then_i_fill_out_and_save_the_note
    user_creates_a_note
  end

  def i_should_see_the_note
    expect(page).to have_css('.modal-body .note .comment', text: "Look at me, I'm a comment")
  end

  def when_i_open_up_a_fulfillment
    first('.otf_fulfillments.list').click
    save_and_open_screenshot
  end

  def when_i_click_on_fulfillment_notes_icon
    
  end
end
