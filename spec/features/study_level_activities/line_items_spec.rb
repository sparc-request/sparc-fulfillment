require 'rails_helper'

feature 'Line Items', js: true do

  context 'User adds a new line item' do
    scenario 'and sees the line item on the page' do
      given_i_am_viewing_the_study_level_activities_tab
      when_i_click_on_the_add_line_item_button
      when_i_fill_in_new_line_item_form
      then_i_should_see_the_line_item_on_the_page
    end

    scenario 'and sees the pricing map data' do
      given_i_am_viewing_the_study_level_activities_tab
      when_i_click_on_the_add_line_item_button
      when_i_fill_in_new_line_item_form
      then_the_line_item_should_pull_pricing_map_data
    end
  end

  context 'User edits an existing line item' do
    scenario 'and sees the changes on the page' do
      given_i_am_viewing_the_study_level_activities_tab
      when_i_click_on_the_edit_line_item_button
      when_i_fill_in_the_edit_line_item_form
      then_i_should_see_the_changes_on_the_page
    end

    scenario 'and sees a note for the changes' do
      given_i_am_viewing_the_study_level_activities_tab
      when_i_click_on_the_edit_line_item_button
      when_i_fill_in_the_edit_line_item_form
      then_i_should_see_the_changes_in_the_notes
    end
  end

  context 'User deletes a line item with fulfillments' do
    scenario 'and sees a flash message' do
      given_i_am_viewing_the_study_level_activities_tab
      when_i_click_on_the_delete_line_item_button_with_fulfillent
      then_i_should_see_a_flash_message
    end
    
    scenario 'and sees the line item' do
      given_i_am_viewing_the_study_level_activities_tab
      when_i_click_on_the_delete_line_item_button_with_fulfillent
      then_i_should_still_see_the_line_item
    end
  end

  context 'User deletes a line item without fulfillments' do
    scenario 'and sees a flash message' do
      given_i_am_viewing_the_study_level_activities_tab
      when_i_click_on_the_delete_line_item_button_without_fulfillment
      then_i_should_see_a_flash_message
    end

    scenario 'and does not see the line item' do
      given_i_am_viewing_the_study_level_activities_tab
      when_i_click_on_the_delete_line_item_button_without_fulfillment
      then_i_should_not_see_the_line_item
    end
  end

  def given_i_am_viewing_the_study_level_activities_tab
    @protocol      = create_and_assign_protocol_to_me
    @service1      = @protocol.organization.inclusive_child_services(:per_participant).first
    @service1.update_attributes(name: 'Admiral Tuskface', one_time_fee: true)
    @service2      = @protocol.organization.inclusive_child_services(:per_participant).second
    @service2.update_attributes(name: 'Captain Cinnebon', one_time_fee: true)
    @pricing_map   = create(:pricing_map, service: @service1, quantity_type: 'Case', effective_date: Time.current)
    @line_item_with_fulfillment = create(:line_item, service: @service1, protocol: @protocol)
    @fulfillment   = create(:fulfillment, line_item: @line_item_with_fulfillment)
    @line_item_without_fulfillment = create(:line_item, service: @service1, protocol: @protocol)

    visit protocol_path(@protocol.id)

    click_link 'Study Level Activities'
  end

  def when_i_click_on_the_add_line_item_button
    first('.otf_service_new').click
  end

  def when_i_click_on_the_delete_line_item_button_with_fulfillent
    find(".line_item[data-id='#{@line_item_with_fulfillment.id}'] .options .otf_delete").click
  end

  def when_i_click_on_the_delete_line_item_button_without_fulfillment
    find(".line_item[data-id='#{@line_item_without_fulfillment.id}'] .options .otf_delete").click
  end

  def when_i_fill_in_new_line_item_form
    wait_for_ajax
    bootstrap_select '#line_item_service_id', 'Admiral Tuskface'
    fill_in 'Quantity Requested', with: 50
    page.execute_script %Q{ $('#date_started_field').trigger("focus") }
    page.execute_script %Q{ $("td.day:contains('15')").trigger("click") }
    click_button 'Save Study Level Activity'
  end

  def when_i_fill_in_the_edit_line_item_form
    wait_for_ajax
    bootstrap_select '#line_item_service_id', 'Captain Cinnebon'
    click_button 'Save Study Level Activity'
    wait_for_ajax
  end

  def then_i_should_see_a_flash_message
    expect(page).to have_css ".alert"
  end

  def then_i_should_not_see_the_line_item
    expect(page).not_to have_css(".line_item[data-id='#{@line_item_without_fulfillment.id}']")
  end

  def then_i_should_still_see_the_line_item
    expect(page).to have_css(".line_item[data-id='#{@line_item_with_fulfillment.id}']")
  end

  def then_i_should_see_the_line_item_on_the_page
    expect(page).to have_content('Admiral Tuskface')
  end

  def when_i_click_on_the_edit_line_item_button
    find(".line_item[data-id='#{@line_item_without_fulfillment.id}'] .options .otf_edit").click
  end

  def then_i_should_see_the_changes_on_the_page
    wait_for_ajax
    expect(page).to have_content('Captain Cinnebon')
  end

  def then_the_line_item_should_pull_pricing_map_data
    expect(page).to have_content('Case')
  end

  def then_i_should_see_the_changes_in_the_notes
    first('.notes.list[data-notable-type="LineItem"]').click
    wait_for_ajax
    expect(page).to have_content "Study Level Activity Updated"
  end
end
