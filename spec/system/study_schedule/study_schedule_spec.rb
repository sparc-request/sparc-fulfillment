# Copyright © 2011-2023 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

require 'rails_helper'

RSpec.describe 'Study Schedule', type: :system, js: true do
  let(:identity)    { @logged_in_identity }
  let(:protocol) do
    p = create_and_assign_blank_protocol_to_me(identity: identity)
    p.sparc_protocol.update(type: 'Study')
    create(:project_role_pi, protocol: p, identity: identity)
    p
  end
  let(:arm)         { create(:arm_with_only_per_patient_line_items, protocol: protocol, visit_count: 10) }
  let(:line_item)   { arm.line_items.first }
  let(:visit_group) { arm.visit_groups.first }
  let(:visit_obj)   { line_item.visits.first } # Renamed to avoid overriding Capybara's native `visit` method
  
  let(:new_service) { line_item.service.organization.inclusive_child_services(:per_participant).last }

  context 'User loads a protocol' do
    it 'sees the study schedule with visit names, line items, and visits' do
      given_i_am_viewing_a_protocol
      then_i_should_see_the_study_schedule_and_its_components
    end
  end

  context 'User selects a new tab' do
    it 'sees the new tab' do
      given_i_am_viewing_a_protocol
      when_i_select_a_new_tab
      then_i_should_see_the_tab
    end

    context 'and reloads the page' do
      it 'sees the same tab' do
        given_i_am_viewing_a_protocol
        when_i_select_a_new_tab
        when_i_refresh_the_page
        then_i_should_see_the_same_tab
      end
    end
  end

  context 'User changes a visit groups name to an invalid name' do
    it 'sees the error message and also sees the name revert to the original' do
      given_i_am_viewing_a_protocol
      when_i_fill_in_a_visit_group_name_with 'vanilla ice cream'
      when_i_fill_in_a_visit_group_name_with ''
      then_it_should_throw_error_message_and_see_that_the_name_is_still 'vanilla ice cream'
    end
  end

  context 'User is on the first page of the calendar' do
    it 'sees the previous page button is disabled' do
      given_i_am_viewing_a_protocol
      when_i_view_the_first_page_of_the_calendar
      then_i_should_see_the_previous_page_button_is_disabled
    end
  end

  context 'User is on the last page of the calendar' do
    it 'sees the next page button is disabled' do
      given_i_am_viewing_a_protocol
      when_i_view_the_last_page_of_the_calendar
      then_i_should_see_the_next_page_button_is_disabled
    end
  end

  context 'User clicks the next page button' do
    it 'sees the next page' do
      given_i_am_viewing_a_protocol
      when_i_click_the_next_page_button
      then_i_should_see_the_next_page
    end
  end

  context 'User clicks the previous page button' do
    it 'sees the previous page' do
      given_i_am_viewing_a_protocol
      when_i_click_the_next_page_button
      when_i_click_the_previous_page_button
      then_i_should_see_the_previous_page
    end
  end

  context 'User selects a visit group from the calendar dropdown' do
    it 'sees the correct page' do
      given_i_am_viewing_a_protocol
      when_i_select_a_visit_group_from_the_dropdown
      then_i_should_see_the_page_change
    end
  end

  context 'User clicks the check all button for a row' do
    it 'sees all visits for the line item are checked' do
      given_i_am_viewing_a_protocol
      when_i_click_a_check_all_row_box
      then_i_should_see_the_row_checked_in_the_tab 'template'
    end
  end

  context 'User clicks the uncheck all button for a row' do
    it 'sees all visits for the line item are unchecked' do
      given_i_am_viewing_a_protocol
      when_i_click_an_uncheck_all_row_box
      then_i_should_see_the_row_unchecked_in_the_tab 'template'
    end
  end

  context 'User clicks the check all button for a column' do
    it 'sees all visits for the visit group are checked' do
      given_i_am_viewing_a_protocol
      when_i_click_a_check_all_column_box
      then_i_should_see_the_column_checked_in_the_tab 'template'
    end
  end

  context 'User clicks the uncheck all button for a column' do
    it 'sees all visits for the visit group are unchecked' do
      given_i_am_viewing_a_protocol
      when_i_click_an_uncheck_all_column_box
      then_i_should_see_the_column_unchecked_in_the_tab 'template'
    end
  end

  context 'User views the quantity/billing tab' do
    context 'and sets a quantity to blank' do
      it 'sees the error message' do
        given_i_am_viewing_a_protocol
        given_i_am_viewing_the_quantity_billing_tab
        when_i_click_the_visit_modal
        when_i_set_the_research_billing_quantity_to ''
        then_i_should_see_not_a_number_error_message
      end
    end

    context 'and sets a quantity to an invalid value' do
      it 'sees the quantity revert to the previous value' do
        given_i_am_viewing_a_protocol
        given_i_am_viewing_the_quantity_billing_tab
        when_i_click_the_visit_modal
        when_i_set_the_research_billing_quantity_to '-1'
        then_i_should_see_greater_than_error_message
      end
    end
  end

  context 'User clicks the line item edit button' do
    it 'sees the line item edit modal' do
      given_i_am_viewing_a_protocol
      when_i_click_the_edit_line_item_button
      then_i_should_see_the_edit_line_item_modal
    end

    it 'sees the inclusive child services of the organization' do
      given_i_am_viewing_a_protocol
      when_i_click_the_edit_line_item_button
      then_i_should_see_the_correct_service
    end

    context 'and saves changes' do
      it 'sees the updated service' do
        given_i_am_viewing_a_protocol
        when_i_click_the_edit_line_item_button
        when_i_set_the_service_to(new_service)
        when_i_submit_the_service_changes
        then_i_should_see_the_updated_service(new_service)
      end
    end
  end

  def given_i_am_viewing_a_protocol
    # Explicitly invoke lazy-loaded `let` bindings to build the data state
    protocol
    arm
    line_item
    visit_group
    visit_obj

    visit protocol_path(protocol.id)
    
    expect(page).to have_css('#studyScheduleTabLink', visible: true)
    find('#studyScheduleTabLink').click
    
    expect(page).to have_css(".study-schedule-container .arm-#{arm.id}-container", visible: true)
  end

  def given_i_am_viewing_the_quantity_billing_tab
    click_link 'Quantity/Billing Tab'
    expect(page).to have_css('.r-label', visible: true) 
  end

  def when_i_select_a_new_tab
    given_i_am_viewing_the_quantity_billing_tab
  end

  def when_i_refresh_the_page
    visit protocol_path(protocol.id)
    expect(page).to have_css('#studyScheduleTabLink', visible: true)
  end

  def when_i_fill_in_a_visit_group_name_with(name)
    fill_in "visit_group_#{visit_group.id}", with: name
    # Safely blur using a body click to trigger the app's validation
    find('body').click(x: 0, y: 0)
  end

  def when_i_view_the_first_page_of_the_calendar
    while page.has_css?("#arrow-left-#{arm.id}:not(.disabled)") && find("#arrow-left-#{arm.id}")[:page].to_i > 0
      when_i_click_the_previous_page_button
    end
  end

  def when_i_view_the_last_page_of_the_calendar
    while arm.visit_groups.count - (find("#arrow-right-#{arm.id}")[:page].to_i - 1) * Visit.per_page > 0
      when_i_click_the_next_page_button
    end
  end

  def when_i_click_the_next_page_button
    current_page = find("#arrow-left-#{arm.id}")[:page].to_i
    target_page = current_page + 1

    find("#arrow-right-#{arm.id}").click
    
    expect(page).to have_css("#arrow-left-#{arm.id}[page='#{target_page}']")
  end

  def when_i_click_the_previous_page_button
    current_page = find("#arrow-left-#{arm.id}")[:page].to_i
    target_page = current_page - 1

    find("#arrow-left-#{arm.id}").click
    
    expect(page).to have_css("#arrow-left-#{arm.id}[page='#{target_page}']")
  end

  def when_i_select_a_visit_group_from_the_dropdown
    find("button[data-id='visits_select_for_#{arm.id}']").click
    
    expect(page).to have_css('.dropdown-menu.show', visible: true)
    
    dropdown_item = all("a.dropdown-item span.text", visible: true)[9]
    selected_text = dropdown_item.text
    
    dropdown_item.click
    
    expect(page).to have_no_css('.dropdown-menu.show')

    expect(page).to have_css("button[data-id='visits_select_for_#{arm.id}']", text: selected_text)
  end

  def when_i_click_a_check_all_row_box
    accept_confirm do
      find("#line_item_#{line_item.id} .check-row").click
    end

    expect(page).to have_css("#line_item_#{line_item.id} input[type=checkbox]:checked", count: Visit.per_page)
  end

  def when_i_click_an_uncheck_all_row_box
    when_i_click_a_check_all_row_box 
    
    accept_confirm do
      find("#line_item_#{line_item.id} .check-row").click
    end

    expect(page).to have_css("#line_item_#{line_item.id} input[type=checkbox]:not(:checked)")
  end

  def when_i_click_a_check_all_column_box
    accept_confirm do
      find("button[data-visit-group-id='#{visit_group.id}']").click
    end

    expect(page).to have_css("input[type=checkbox]:checked", count: arm.line_items.count)
  end

  def when_i_click_an_uncheck_all_column_box
    when_i_click_a_check_all_column_box 
    
    accept_confirm do
      find("button[data-visit-group-id='#{visit_group.id}']").click
    end
    expect(page).to have_no_css("input[type=checkbox]:checked")
  end

  def when_i_click_the_visit_modal
    find("#visit#{visit_obj.id} a", match: :first).click

    expect(page).to have_css('.modal-content', text: /Research billing qty/i, visible: true)
  end

  def when_i_set_the_research_billing_quantity_to(value)
    expect(page).to have_css('.modal-content', text: /Edit Billing Quantities/i, visible: true)
    expect(page).to have_css("#visit_research_billing_qty", visible: true)

    within('.modal-content', text: /Edit Billing Quantities/i) do
      fill_in "visit_research_billing_qty", with: value
    end

    find('body').click(x: 0, y: 0)
    
    within('.modal-content', text: /Edit Billing Quantities/i) do
      click_button "Submit"
    end
  end

  def when_i_click_the_edit_line_item_button
    find("#line_item_#{line_item.id} .change-line-item-service").click
    expect(page).to have_css('.modal-content', text: /Change Service/i, visible: true)
  end

  def when_i_set_the_service_to(service)
    within('.modal-content', text: /Change Service/i) do
      bootstrap_select "#line_item_service_id", service.name
    end
  end

  def when_i_submit_the_service_changes
    within('.modal-content', text: /Change Service/i) do
      find("input[type='submit']").click
    end

    expect(page).to have_no_css('.modal-content', text: /Change Service/i)
  end

  def then_i_should_see_the_study_schedule_and_its_components
    expect(page).to have_css(".study-schedule-container .arm-#{arm.id}-container")
    expect(page).to have_css("#visit-name-display-#{visit_group.id}")
    expect(page).to have_css("#line_item_#{line_item.id}")
    expect(page).to have_css("#visit_check_#{visit_obj.id}")
  end

  def then_i_should_see_the_tab
    expect(page).to have_css(".r-label")
    expect(page).to have_css(".t-label")
  end

  def then_i_should_see_the_same_tab
    then_i_should_see_the_tab
  end

  def then_it_should_throw_error_message_and_see_that_the_name_is_still(name)
    expect(page).to have_content(/Visit Name can't be blank/i)
    expect(page).to have_field("visit_group_#{visit_group.id}", with: name)
  end

  def then_i_should_see_the_previous_page_button_is_disabled
    expect(page).to have_css("#arrow-left-#{arm.id}.disabled")
  end

  def then_i_should_see_the_next_page_button_is_disabled
    expect(page).to have_css("#arrow-right-#{arm.id}.disabled")
  end

  def then_i_should_see_the_next_page
    expect(page).to have_css("#arrow-left-#{arm.id}[page='1']")
  end

  def then_i_should_see_the_previous_page
    expect(page).to have_css("#arrow-left-#{arm.id}[page='0']")
  end

  def then_i_should_see_the_page_change
    expect(page).not_to have_css("#arrow-left-#{arm.id}[page='0']")
  end

  def then_i_should_see_the_row_checked_in_the_tab(tab_name)
    case tab_name.downcase
    when 'template'
      expect(page).to have_css("#line_item_#{line_item.id} input[type=checkbox]:checked", count: Visit.per_page)
    when 'quantity/billing'
      expect(page).to have_field(/Research/i, with: '1', minimum: 1)
      all("#line_item_#{line_item.id} .research").each do |quantity|
        expect(quantity.value).to eq('1')
      end
    end
  end

  def then_i_should_see_the_row_unchecked_in_the_tab(tab_name)
    case tab_name.downcase
    when 'template'
      expect(page).to have_no_css("#line_item_#{line_item.id} input[type=checkbox]:checked")
    when 'quantity/billing'
      expect(page).to have_field(/Research/i, with: '0', minimum: 1)
      all('.research').each do |quantity|
        expect(quantity.value).to eq('0')
      end
    end
  end

  def then_i_should_see_the_column_checked_in_the_tab(tab_name)
    case tab_name.downcase
    when 'template'
      expect(page).to have_css('input[type=checkbox]:checked', count: arm.line_items.count)
    when 'quantity/billing'
      expect(find("#visits_#{visit_obj.id}_research_billing_qty").value).to eq('1')
      expect(find("#visits_#{visit_obj.id}_insurance_billing_qty").value).to eq('0')
    end
  end

  def then_i_should_see_the_column_unchecked_in_the_tab(tab_name)
    case tab_name.downcase
    when 'template'
      expect(page).to have_no_css('input[type=checkbox]:checked')
    when 'quantity/billing'
      expect(find("#visits_#{visit_obj.id}_research_billing_qty").value).to eq('0')
      expect(find("#visits_#{visit_obj.id}_insurance_billing_qty").value).to eq('0')
    end
  end

  def then_i_should_see_not_a_number_error_message
    expect(page).to have_content(/Is not a number/i, wait: 10)
  end

  def then_i_should_see_greater_than_error_message
    expect(page).to have_content(/Must be greater than or equal to 0/i, wait: 10)
  end

  def then_i_should_see_the_edit_line_item_modal
    expect(page).to have_content(/Change Service/i)
  end

  def then_i_should_see_the_correct_service
    # Rule III.B: Scope the interaction strictly to the modal
    within('.modal-content', text: /Change Service/i) do
      
      # Rule II.A: Apply the brakes. Give the CI server up to 10 seconds for Bootstrap Select to build the element.
      expect(page).to have_css("button.dropdown-toggle[data-id='line_item_service_id']", visible: true, wait: 10)
      
      # Now that we have proven the element exists and is visible, safely evaluate its attribute
      expect(find("button.dropdown-toggle[data-id='line_item_service_id']")["title"]).to match(/#{Regexp.quote(line_item.service.name)}/i)
    end
  end

  def then_i_should_see_the_updated_service(service)
    expect(page).to have_css(".line_item_service_name", text: /#{Regexp.quote(service.name)}/i)
  end
end