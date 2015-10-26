require 'rails_helper'

feature 'Fulfillments', js: true do

  context 'User adds a new fulfillment' do
    scenario 'and sees the fulfillment' do
      given_i_have_study_level_activities
      given_i_am_viewing_the_study_level_activities_tab
      when_i_open_up_a_fulfillment
      when_i_click_on_the_add_fulfillment_button
      when_i_fill_out_the_fulfillment_form
      when_i_save_the_fulfillment_form
      then_i_should_see_the_new_fulfillment_in_the_table
    end

    scenario 'and sees the components' do
      given_i_have_study_level_activities
      given_i_am_viewing_the_study_level_activities_tab
      when_i_open_up_a_fulfillment
      when_i_click_on_the_add_fulfillment_button
      when_i_fill_out_the_fulfillment_form
      when_i_save_the_fulfillment_form
      then_i_should_see_the_correct_components
    end
  end

  context 'User adds a new fulfillment incorrectly' do
    scenario 'and sees form errors' do
      given_i_have_study_level_activities
      given_i_am_viewing_the_study_level_activities_tab
      when_i_open_up_a_fulfillment
      when_i_click_on_the_add_fulfillment_button
      when_i_save_the_fulfillment_form
      then_i_should_see_form_errors
    end
  end

  context 'User edits an existing fulfillment' do
    scenario 'and sees the fulfillment' do
      given_i_have_study_level_activities
      given_i_have_a_fulfillment
      given_i_am_viewing_the_study_level_activities_tab
      when_i_open_up_a_fulfillment
      when_i_click_on_the_edit_fulfillment_button
      when_i_fill_out_the_fulfillment_form
      when_i_save_the_fulfillment_form
      then_i_should_see_the_new_fulfillment_in_the_table
    end

    scenario 'and sees the components' do
      given_i_have_study_level_activities
      given_i_have_a_fulfillment
      given_i_am_viewing_the_study_level_activities_tab
      when_i_open_up_a_fulfillment
      when_i_click_on_the_edit_fulfillment_button
      when_i_fill_out_the_fulfillment_form
      when_i_save_the_fulfillment_form
      then_i_should_see_the_correct_components
    end

    scenario 'and sees a note for the changes' do
      given_i_have_study_level_activities
      given_i_have_a_fulfillment
      given_i_am_viewing_the_study_level_activities_tab
      when_i_open_up_a_fulfillment
      when_i_click_on_the_edit_fulfillment_button
      when_i_fill_out_the_fulfillment_form
      when_i_save_the_fulfillment_form
      then_i_should_see_the_changes_in_the_notes
    end
  end

  def given_i_have_study_level_activities
    @protocol = create_and_assign_protocol_to_me
    service     = create(:service_with_one_time_fee)
    @line_item  = create(:line_item, protocol: @protocol, service: service)
    @components = @line_item.components
    @clinical_providers = Identity.first.clinical_providers
  end

  def given_i_have_a_fulfillment
    @fulfillment = create(:fulfillment, line_item: @line_item)
  end

  def given_i_am_viewing_the_study_level_activities_tab
    visit protocol_path(@protocol.id)
    wait_for_ajax
    click_link "Study Level Activities"
    wait_for_ajax
  end

  def when_i_open_up_a_fulfillment
    first(".otf_fulfillments.list").click
    wait_for_ajax
  end

  def when_i_click_on_the_add_fulfillment_button
    click_button "Add Fulfillment"
    wait_for_ajax
  end

  def when_i_click_on_the_edit_fulfillment_button
    first("#fulfillments-table .available-actions-button").click
    wait_for_ajax
    find(".otf_fulfillment_edit").click
    wait_for_ajax
  end

  def when_i_fill_out_the_fulfillment_form
    page.execute_script %Q{ $('#date_fulfilled_field').trigger("focus") }
    page.execute_script %Q{ $("td.day:contains('15')").trigger("click") }
    fill_in 'Quantity', with: "45"
    bootstrap_select '#fulfillment_performer_id', @clinical_providers.first.identity.full_name
    bootstrap_select '#fulfillment_components', @components.first.component
    find('.modal-header').click
    wait_for_ajax
  end

  def when_i_save_the_fulfillment_form
    click_button "Save Fulfillment"
    wait_for_ajax
  end

  def then_i_should_see_the_new_fulfillment_in_the_table
    expect(page).to have_css("#fulfillments-table tr[data-index='0']")
  end

  def then_i_should_see_the_correct_components
    click_button "Display Components"
    wait_for_ajax
    expect(first('.dropdown-menu > li').text).to eq @components.first.component
    first('.dropdown-menu > li').click
    wait_for_ajax
  end

  def then_i_should_see_form_errors
    expect(page).to have_content("Fulfilled at can't be blank")
    expect(page).to have_content("Quantity can't be blank")
    expect(page).to have_content("Quantity is not a number")
  end

  def then_i_should_see_the_changes_in_the_notes
    first("#fulfillments-table .available-actions-button").click
    wait_for_ajax
    first('.notes.list[data-notable-type="Fulfillment"]').click
    wait_for_ajax
    expect(page).to have_content "Quantity changed to 45"
  end
end
