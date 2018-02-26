# Copyright © 2011-2018 MUSC Foundation for Research Development~
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

RSpec.describe 'Study Schedule', js: true do

  context 'User loads a protocol' do
    scenario 'and sees the study schedule with visit names, line items, and visits' do
      given_i_am_viewing_a_protocol
      then_i_should_see_the_study_schedule_and_its_components
    end
  end

  context 'User selects a new tab' do
    scenario 'and sees the new tab' do
      given_i_am_viewing_a_protocol
      when_i_select_a_new_tab
      then_i_should_see_the_tab
    end

    context 'and reloads the page' do
      scenario 'and sees the same tab' do
        given_i_am_viewing_a_protocol
        when_i_select_a_new_tab
        when_i_refresh_the_page
        then_i_should_see_the_same_tab
      end
    end
  end

  context 'User changes a visit groups name to an invalid name' do
    scenario 'and sees the name revert to the original' do
      given_i_am_viewing_a_protocol
      when_i_fill_in_a_visit_group_name_with 'vanilla ice cream'
      when_i_fill_in_a_visit_group_name_with ''
      then_i_should_see_that_the_name_is_still 'vanilla ice cream'
    end
  end

  context 'User is on the first page of the calendar' do
    scenario 'and sees the previous page button is disabled' do
      given_i_am_viewing_a_protocol
      when_i_view_the_first_page_of_the_calendar
      then_i_should_see_the_previous_page_button_is_disabled
    end
  end

  context 'User is on the last page of the calendar' do
    scenario 'and sees the next page button is disabled' do
      given_i_am_viewing_a_protocol
      when_i_view_the_last_page_of_the_calendar
      then_i_should_see_the_next_page_button_is_disabled
    end
  end

  context 'User clicks the next page button' do
    scenario 'and sees the next page' do
      given_i_am_viewing_a_protocol
      when_i_click_the_next_page_button
      then_i_should_see_the_next_page
    end
  end

  context 'User clicks the previous page button' do
    scenario 'and sees the previous page' do
      given_i_am_viewing_a_protocol
      when_i_click_the_next_page_button
      when_i_click_the_previous_page_button
      then_i_should_see_the_previous_page
    end
  end

  context 'User selects a visit group from the calendar dropdown' do
    scenario 'and sees the correct page' do
      given_i_am_viewing_a_protocol
      when_i_select_a_visit_group_from_the_dropdown
      then_i_should_see_the_page_change
    end
  end

  context 'User clicks the check all button for a row' do
    scenario 'and sees all visits for the line item are checked' do
      given_i_am_viewing_a_protocol
      when_i_click_a_check_all_row_box
      then_i_should_see_the_row_checked_in_the_tab 'template'
    end
  end

  context 'User clicks the uncheck all button for a row' do
    scenario 'and sees all visits for the line item are unchecked' do
      given_i_am_viewing_a_protocol
      when_i_click_an_uncheck_all_row_box
      then_i_should_see_the_row_unchecked_in_the_tab 'template'
    end
  end

  context 'User clicks the check all button for a column' do
    scenario 'and sees all visits for the visit group are checked' do
      given_i_am_viewing_a_protocol
      when_i_click_a_check_all_column_box
      then_i_should_see_the_column_checked_in_the_tab 'template'
    end
  end

  context 'User clicks the uncheck all button for a column' do
    scenario 'and sees all visits for the visit group are unchecked' do
      given_i_am_viewing_a_protocol
      when_i_click_an_uncheck_all_column_box
      then_i_should_see_the_column_unchecked_in_the_tab 'template'
    end
  end

  context 'User views the quantity/billing tab' do
    context 'and sets a quantity to blank' do
      scenario 'and sees the quantity revert to the previous value' do
        given_i_am_viewing_a_protocol
        given_i_am_viewing_the_quantity_billing_tab
        when_i_set_the_research_billing_quantity_to '6'
        when_i_set_the_research_billing_quantity_to ''
        then_i_should_see_the_research_billing_quantity_is '6'
      end
    end

    context 'and sets a quantity to an invalid value' do
      scenario 'and sees the quantity revert to the previous value' do
        given_i_am_viewing_a_protocol
        given_i_am_viewing_the_quantity_billing_tab
        when_i_set_the_research_billing_quantity_to '6'
        when_i_set_the_research_billing_quantity_to '-1'
        then_i_should_see_the_research_billing_quantity_is '6'
      end
    end
  end

  context 'User clicks the line item edit button' do
    scenario 'and sees the line item edit modal' do
      given_i_am_viewing_a_protocol
      when_i_click_the_edit_line_item_button
      then_i_should_see_the_edit_line_item_modal
    end

    scenario 'and sees the inclusive child services of the organization' do
      given_i_am_viewing_a_protocol
      when_i_click_the_edit_line_item_button
      then_i_should_see_the_correct_services
    end

    context 'and saves changes' do
      scenario 'and sees the updated service' do
        given_i_am_viewing_a_protocol
        when_i_click_the_edit_line_item_button
        @service = @line_item.service.organization.inclusive_child_services(:per_participant).last
        when_i_set_the_service_to @service
        when_i_submit_the_service_changes
        then_i_should_see_the_updated_service
      end
    end
  end

  def given_i_am_viewing_a_protocol
    @protocol       = create_and_assign_blank_protocol_to_me
    sparc_protocol = @protocol.sparc_protocol
    sparc_protocol.update_attributes(type: 'Study')
    project_role    = create(:project_role_pi, protocol: @protocol)
    @arm            = create(:arm_with_only_per_patient_line_items, protocol: @protocol, visit_count: 10)
    @line_item      = @arm.line_items.first
    @visit_group    = @arm.visit_groups.first
    @visit          = @line_item.visits.first
    visit protocol_path(@protocol.id)
    wait_for_ajax
  end

  def given_i_am_viewing_the_quantity_billing_tab
    click_link 'Quantity/Billing Tab'
    wait_for_ajax
  end

  def when_i_select_a_new_tab
    click_link "Quantity/Billing Tab"
    wait_for_ajax
  end

  def when_i_refresh_the_page
    visit protocol_path(@protocol.id)
    wait_for_ajax
  end

  def when_i_fill_in_a_visit_group_name_with name
    fill_in "visit_group_#{@visit_group.id}", with: name
    first('.study_schedule.service').click()
    wait_for_ajax
  end

  def when_i_view_the_first_page_of_the_calendar
    while find("#arrow-left-#{@arm.id}")[:page].to_i > 0
      when_i_click_the_previous_page_button #Press previous page until at page 1
    end
  end

  def when_i_view_the_last_page_of_the_calendar
    while @arm.visit_groups.count - (find("#arrow-right-#{@arm.id}")[:page].to_i - 1) * Visit.per_page > 0
      when_i_click_the_next_page_button #Press next page until at final page
    end
  end

  def when_i_click_the_next_page_button
    @page = find("#arrow-left-#{@arm.id}")[:page].to_i + 1
    find("#arrow-right-#{@arm.id}").trigger("click")
    wait_for_ajax
  end

  def when_i_click_the_previous_page_button
    @page = find("#arrow-left-#{@arm.id}")[:page].to_i + 1
    find("#arrow-left-#{@arm.id}").click()
    wait_for_ajax
  end

  def when_i_select_a_visit_group_from_the_dropdown
    @page = find("#arrow-left-#{@arm.id}")[:page].to_i + 1
    data_id = "visits_select_for_#{@arm.id}"
    find("button[data-id = #{data_id}]").click()
    all(".visit_dropdown ul.dropdown-menu li a")[10].click()
    wait_for_ajax
  end

  def when_i_click_a_check_all_row_box
    @alert = accept_confirm(with: "This will reset custom values for this row, do you wish to continue?") do
      find("#line_item_#{@line_item.id} .check_row").click()
    end
    expect(@alert).to eq("This will reset custom values for this row, do you wish to continue?")
    wait_for_ajax
  end

  def when_i_click_an_uncheck_all_row_box
    when_i_click_a_check_all_row_box #Check
    when_i_click_a_check_all_row_box #Uncheck
  end

  def when_i_click_a_check_all_column_box
    @alert = accept_confirm(with: "This will reset custom values for this column, do you wish to continue?") do
      first(".check_column").click()
    end
    expect(@alert).to eq("This will reset custom values for this column, do you wish to continue?")
    wait_for_ajax
  end

  def when_i_click_an_uncheck_all_column_box
    when_i_click_a_check_all_column_box #Check
    when_i_click_a_check_all_column_box #Uncheck
  end

  def when_i_set_the_research_billing_quantity_to value
    fill_in "visits_#{@visit.id}_research_billing_qty", :with => value
    first('.study_schedule.service').click()
    wait_for_ajax
  end

  def when_i_click_the_edit_line_item_button
    first(".change_line_item_service").click
    wait_for_ajax
    
  end

  def when_i_set_the_service_to service
    bootstrap_select "#line_item_service_id", service.name
    wait_for_ajax
  end

  def when_i_submit_the_service_changes
    click_button 'Save'
    wait_for_ajax
  end

  def then_i_should_see_the_study_schedule_and_its_components
    expect(page).to have_css(".study_schedule.service.arm_#{@arm.id}")
    expect(page).to have_css("#visit-name-display-#{@visit_group.id}")
    expect(page).to have_css("#line_item_#{@line_item.id}")
    expect(page).to have_css("#visit_check_#{@visit.id}")
  end

  def then_i_should_see_the_tab
    expect(page).to have_css("#visits_#{@visit.id}_research_billing_qty")
    expect(page).to have_css("#visits_#{@visit.id}_insurance_billing_qty")
  end

  def then_i_should_see_the_same_tab
    expect(page).to have_css("#visits_#{@visit.id}_research_billing_qty")
    expect(page).to have_css("#visits_#{@visit.id}_insurance_billing_qty")
  end

  def then_i_should_see_that_the_name_is_still name
    expect(find_field("visit_group_#{@visit_group.id}").value).to eq(name)
  end

  def then_i_should_see_the_previous_page_button_is_disabled
    expect(page).to have_css("#arrow-left-#{@arm.id}[disabled]")
  end

  def then_i_should_see_the_next_page_button_is_disabled
    expect(page).to have_css("#arrow-right-#{@arm.id}[disabled]")
  end

  def then_i_should_see_the_next_page
    expect(find("#arrow-left-#{@arm.id}")[:page].to_i).to eq(@page)
  end

  def then_i_should_see_the_previous_page
    expect(find("#arrow-left-#{@arm.id}")[:page].to_i).to eq(@page-2)
  end

  def then_i_should_see_the_page_change
    expect(find("#arrow-left-#{@arm.id}")[:page].to_i).to eq(@page)
  end

  def then_i_should_see_the_row_checked_in_the_tab tab_name
    case tab_name
      when 'template'
        expect(all("#line_item_#{@line_item.id} input[type=checkbox]:checked").count).to eq(Visit.per_page)
      when 'quantity/billing'
        all("#line_item_#{@line_item.id} .research").each do |quantity|
          expect(quantity.value).to eq('1')
        end
    end
  end

  def then_i_should_see_the_row_unchecked_in_the_tab tab_name
    case tab_name
      when 'template'
        expect(all("#line_item_#{@line_item.id} input[type=checkbox]:checked").count).to eq(0)
      when 'quantity/billing'
        all('.research').each do |quantity|
          expect(quantity.value).to eq('0')
        end
    end
  end

  def then_i_should_see_the_column_checked_in_the_tab tab_name
    case tab_name
      when 'template'
        expect(all('input[type=checkbox]:checked').count).to eq(@arm.line_items.count)
      when 'quantity/billing'
        expect(find("#visits_#{@visit.id}_research_billing_qty").value).to eq('1')
        expect(find("#visits_#{@visit.id}_insurance_billing_qty").value).to eq('0')
    end
  end

  def then_i_should_see_the_column_unchecked_in_the_tab tab_name
    case tab_name
      when 'template'
        expect(all('input[type=checkbox]:checked').count).to eq(0)
      when 'quantity/billing'
        expect(find("#visits_#{@visit.id}_research_billing_qty").value).to eq('0')
        expect(find("#visits_#{@visit.id}_insurance_billing_qty").value).to eq('0')
    end
  end

  def then_i_should_see_the_research_billing_quantity_is value
    expect(find_field("visits_#{@visit.id}_research_billing_qty").value).to eq(value)
  end

  def then_i_should_see_the_edit_line_item_modal
    expect(page).to have_content("Change Service")
  end

  def then_i_should_see_the_correct_services
    services = @line_item.service.organization.inclusive_child_services(:per_participant)
    index = 0

    all(".text").each do |service|
      expect(service.text).to eq(services[index])
      index += 1
    end
  end

  def then_i_should_see_the_updated_service
    expect(page).to have_css(".line_item_service_name", text: @service.name)
  end
end
