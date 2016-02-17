require 'rails_helper'

feature 'Notes', js: true do

  context 'User views line item notes' do
    scenario 'and sees the line item notes list' do
      given_i_am_viewing_the_study_level_activities_tab
      when_i_click_on_line_item_notes_icon
      then_i_should_see_the_line_item_notes_list
    end
  end

  context 'User creates line item note' do
    scenario 'and sees the note in the line items notes list' do
      given_i_am_viewing_the_study_level_activities_tab
      when_i_click_on_line_item_notes_icon
      when_i_click_on_the_add_note_button
      when_i_fill_out_and_save_the_note
      when_i_click_on_line_item_notes_icon
      then_i_should_see_the_note
    end
  end

  context 'User views fulfillment notes' do
    scenario 'and sees the fulfillments notes list' do
      given_i_am_viewing_the_study_level_activities_tab
      when_i_open_up_a_fulfillment
      when_i_click_on_fulfillment_notes_icon
      then_i_should_see_the_fulfillment_notes_list
    end
  end

  context 'User creates fulfillment note' do
    scenario 'and sees the note in the fulfillments notes list' do
      given_i_am_viewing_the_study_level_activities_tab
      when_i_open_up_a_fulfillment
      when_i_click_on_fulfillment_notes_icon
      when_i_click_on_the_add_note_button
      when_i_fill_out_and_save_the_note
      when_i_click_on_fulfillment_notes_icon
      then_i_should_see_the_note
    end
  end

  def given_i_am_viewing_the_study_level_activities_tab
    protocol = create_and_assign_protocol_to_me
    sparc_protocol = protocol.sparc_protocol
    sparc_protocol.update_attributes(type: 'Study')
    visit protocol_path(protocol.id)
    wait_for_ajax
    click_link "Study Level Activities"
    wait_for_ajax
  end

  def when_i_open_up_a_fulfillment
    first('.otf_fulfillments.list').click
    wait_for_ajax
  end

  def when_i_click_on_line_item_notes_icon
    first("#study-level-activities-table .available-actions-button").click
    wait_for_ajax
    first('.notes.list[data-notable-type="LineItem"]').click
    wait_for_ajax
  end

  def when_i_click_on_fulfillment_notes_icon
    first("#fulfillments-table .available-actions-button").click
    wait_for_ajax
    first('.notes.list[data-notable-type="Fulfillment"]').click
    wait_for_ajax
  end

  def when_i_click_on_the_add_note_button
    find('.note.new').click
    wait_for_ajax
  end

  def when_i_fill_out_and_save_the_note
    fill_in 'note_comment', with: "Test Comment"
    wait_for_ajax
    click_button 'Save'
    wait_for_ajax
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
