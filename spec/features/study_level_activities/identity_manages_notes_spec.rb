require 'rails_helper'

feature 'Notes', js: true do

  describe 'managing line item notes' do

    it 'should be able to create a line item note' do
      given_i_am_viewing_the_study_level_activities_tab
      count = @line_item.notes.count
      when_i_open_up_a_new_line_item_note
      then_i_fill_out_and_save_the_note
      expect(@line_item.notes.count).to eq(count + 1)
    end
  end

  describe 'managing fulfillment notes' do

    it 'should be able to create a fulfillment note' do
      given_i_am_viewing_the_study_level_activities_tab
      count = @fulfillment.notes.count
      when_i_open_up_a_new_fulfillment_note
      then_i_fill_out_and_save_the_note
      expect(@fulfillment.notes.count).to eq(count + 1)
    end
  end

  def given_i_am_viewing_the_study_level_activities_tab
    protocol = create_and_assign_protocol_to_me
    sparc_protocol = protocol.sparc_protocol
    @line_item = protocol.line_items.first
    @fulfillment=  @line_item.fulfillments.first
    sparc_protocol.update_attributes(type: 'Study')
    visit protocol_path(protocol.id)
    wait_for_ajax
    click_link "Study Level Activities"
    wait_for_ajax
  end

  def when_i_open_up_a_new_line_item_note
    first("#study-level-activities-table .available-actions-button").click
    wait_for_ajax
    first('.notes.list[data-notable-type="LineItem"]').click
    wait_for_ajax
    find('.note.new').click
    wait_for_ajax
  end

  def when_i_open_up_a_new_fulfillment_note
    first('.otf-fulfillment-list').click
    wait_for_ajax
    first("#fulfillments-table .available-actions-button").click
    wait_for_ajax
    first('.notes.list[data-notable-type="Fulfillment"]').click
    wait_for_ajax
    find('.note.new').click
    wait_for_ajax
  end

  def then_i_fill_out_and_save_the_note
    fill_in 'note_comment', with: "Test Comment"
    wait_for_ajax
    click_button 'Save'
    wait_for_ajax
  end
end
