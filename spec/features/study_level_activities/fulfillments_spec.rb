require 'rails_helper'

feature 'Fulfillments', js: true do

  scenario 'User adds a new fulfillment' do
    as_a_user_who_has_study_level_activities
    as_a_user_who_visits_study_level_activities_tab
    when_i_open_up_a_fulfillment
    when_i_click_on_the_add_fulfillment_button
    when_i_fill_out_the_fulfillment_form
    when_i_save_the_fulfillment_form
    then_i_should_see_the_new_fulfillment_in_the_table
    then_i_should_see_the_correct_components
  end

  scenario 'User adds a new fulfillment incorrectly' do
    as_a_user_who_has_study_level_activities
    as_a_user_who_visits_study_level_activities_tab
    when_i_open_up_a_fulfillment
    when_i_click_on_the_add_fulfillment_button
    when_i_save_the_fulfillment_form
    then_i_should_see_form_errors
  end

  scenario 'User edits an existing fulfillment' do
    as_a_user_who_has_study_level_activities
    as_a_user_who_has_a_fulfillment
    as_a_user_who_visits_study_level_activities_tab
    when_i_open_up_a_fulfillment
    when_i_click_on_the_edit_fulfillment_button
    when_i_fill_out_the_fulfillment_form
    when_i_save_the_fulfillment_form
    then_i_should_see_the_new_fulfillment_in_the_table
    then_i_should_see_the_correct_components
  end

  def as_a_user_who_has_study_level_activities
    @protocol    = create(:protocol_imported_from_sparc)
    service     = create(:service_of_otf_with_components)
    @line_item  = create(:line_item, protocol: @protocol, service: service)
    @components = @line_item.components
  end

  def as_a_user_who_has_a_fulfillment
    @fulfillment = create(:fulfillment, line_item: @line_item)
  end

  def as_a_user_who_visits_study_level_activities_tab
    visit protocol_path(@protocol.sparc_id)
    click_link "Study Level Activities"
  end

  def when_i_open_up_a_fulfillment
    first(".line_item[data-id='#{@line_item.id}'] > .fulfillments > .otf_fulfillments.list").click
  end

  def when_i_click_on_the_add_fulfillment_button
    click_button "Add Fulfillment"
    wait_for_ajax
  end

  def when_i_click_on_the_edit_fulfillment_button
    fulfillment_row = find(".fulfillment[data-id='#{@fulfillment.id}']")
    within fulfillment_row do
      find(".otf_fulfillment_edit").click
    end
  end

  def when_i_fill_out_the_fulfillment_form
    page.execute_script %Q{ $('#date_fulfilled_field').trigger("focus") }
    page.execute_script %Q{ $("td.day:contains('15')").trigger("click") }
    fill_in 'Quantity', with: "45"
    bootstrap_select '#fulfillment_performer_id', User.first.full_name
    bootstrap_select '#fulfillment_components', @components.first.component
    find('.modal-header').click
  end

  def when_i_save_the_fulfillment_form
    click_button "Save Fulfillment"
    wait_for_ajax
  end

  def then_i_should_see_the_new_fulfillment_in_the_table
    expect(page).to have_css(".row.fulfillment")
  end

  def then_i_should_see_the_correct_components
    click_button "Fulfillment Components"
    expect(first('.dropdown-menu > li').text).to eq @components.first.component
  end

  def then_i_should_see_form_errors
    expect(page).to have_content("Fulfilled at can't be blank")
    expect(page).to have_content("Quantity can't be blank")
    expect(page).to have_content("Quantity is not a number")
    expect(page).to have_content("Performer can't be blank")
  end
end