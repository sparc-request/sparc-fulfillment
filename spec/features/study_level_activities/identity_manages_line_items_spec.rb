# Copyright © 2011-2016 MUSC Foundation for Research Development~
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

feature 'Line Items', js: true do

  context 'User adds a new line item' do
    scenario 'and sees the line item on the page' do
      given_i_am_viewing_the_study_level_activities_tab_with_fulfillments
      when_i_click_on_the_add_line_item_button
      when_i_fill_in_new_line_item_form
      then_i_should_see_the_line_item_on_the_page
    end

    scenario 'and sees the pricing map data' do
      given_i_am_viewing_the_study_level_activities_tab_with_fulfillments
      when_i_click_on_the_add_line_item_button
      when_i_fill_in_new_line_item_form
      then_the_line_item_should_pull_pricing_map_data
    end
  end

  context 'User edits an existing line item' do
    scenario 'and sees the changes on the page' do
      given_i_am_viewing_the_study_level_activities_tab_with_fulfillments
      when_i_click_on_the_edit_line_item_button
      when_i_fill_in_the_edit_line_item_form
      then_i_should_see_the_changes_on_the_page
    end

    scenario 'and sees a note for the changes' do
      given_i_am_viewing_the_study_level_activities_tab_with_fulfillments
      when_i_click_on_the_edit_line_item_button
      when_i_fill_in_the_edit_line_item_form
      then_i_should_see_the_changes_in_the_notes
    end
  end

  context 'User deletes a line item with fulfillments' do
    scenario 'and sees a flash message' do
      given_i_am_viewing_the_study_level_activities_tab_with_fulfillments
      when_i_click_on_the_delete_line_item_button
      then_i_should_see_a_flash_message
    end

    scenario 'and sees the line item' do
      given_i_am_viewing_the_study_level_activities_tab_with_fulfillments
      when_i_click_on_the_delete_line_item_button
      then_i_should_still_see_the_line_item
    end
  end

  context 'User deletes a line item without fulfillments' do
    scenario 'and sees a flash message' do
      given_i_am_viewing_the_study_level_activities_tab_without_fulfillments
      when_i_click_on_the_delete_line_item_button
      then_i_should_see_a_flash_message
    end

    scenario 'and does not see the line item' do
      given_i_am_viewing_the_study_level_activities_tab_without_fulfillments
      when_i_click_on_the_delete_line_item_button
      then_i_should_not_see_the_line_item
    end
  end

  def given_i_am_viewing_the_study_level_activities_tab_with_fulfillments
    @protocol      = create_and_assign_protocol_to_me
    sparc_protocol = @protocol.sparc_protocol
    sparc_protocol.update_attributes(type: 'Study')
    @service1      = @protocol.organization.inclusive_child_services(:per_participant).first
    @service1.update_attributes(name: 'Admiral Tuskface', one_time_fee: true)
    @pricing_map   = create(:pricing_map, service: @service1, quantity_type: 'Case', effective_date: Time.current)
    @line_item_with_fulfillment = create(:line_item, service: @service1, protocol: @protocol)
    @fulfillment   = create(:fulfillment, line_item: @line_item_with_fulfillment)

    visit protocol_path(@protocol.id)
    wait_for_ajax

    click_link 'Non-clinical Services'
    wait_for_ajax
  end

  def given_i_am_viewing_the_study_level_activities_tab_without_fulfillments
    @protocol      = create_and_assign_protocol_to_me
    sparc_protocol = @protocol.sparc_protocol
    sparc_protocol.update_attributes(type: 'Study')
    @service2      = @protocol.organization.inclusive_child_services(:per_participant).second
    @service2.update_attributes(name: 'Captain Cinnebon', one_time_fee: true)

    @protocol.line_items.destroy_all

    @line_item_without_fulfillment = create(:line_item, service: @service2, protocol: @protocol)

    visit protocol_path(@protocol.id)
    wait_for_ajax

    click_link 'Non-clinical Services'
    wait_for_ajax
  end

  def when_i_click_on_the_add_line_item_button
    first('.otf_service_new').click
    wait_for_ajax
  end

  def when_i_click_on_the_delete_line_item_button
    first("#study-level-activities-table .available-actions-button").click
    wait_for_ajax
    find(".otf_delete").click
    wait_for_ajax
  end

  def when_i_fill_in_new_line_item_form
    bootstrap_select '#line_item_service_id', 'Admiral Tuskface'
    fill_in 'Quantity', with: 50
    page.execute_script %Q{ $('#date_started_field').trigger("focus") }
    page.execute_script %Q{ $("td.day:contains('15')").trigger("click") }
    click_button 'Save'
    wait_for_ajax
  end

  def when_i_fill_in_the_edit_line_item_form
    bootstrap_select '#line_item_service_id', 'Admiral Tuskface'
    click_button 'Save'
    wait_for_ajax
  end

  def then_i_should_see_a_flash_message
    expect(page).to have_css ".alert"
  end

  def then_i_should_not_see_the_line_item
    expect(page).to_not have_content("#{@service2.name}") #without fulfillments
  end

  def then_i_should_still_see_the_line_item
    expect(page).to have_content("#{@service1.name}") #with fulfillments
  end

  def then_i_should_see_the_line_item_on_the_page
    expect(page).to have_content('Admiral Tuskface')
  end

  def when_i_click_on_the_edit_line_item_button
    first("#study-level-activities-table .available-actions-button").click
    wait_for_ajax
    find(".otf_edit").click
    wait_for_ajax
  end

  def then_i_should_see_the_changes_on_the_page
    expect(page).to have_content('Admiral Tuskface')
  end

  def then_the_line_item_should_pull_pricing_map_data
    expect(page).to have_content('Case')
  end

  def then_i_should_see_the_changes_in_the_notes
    first("#study-level-activities-table .available-actions-button").click
    wait_for_ajax
    first('.notes.list[data-notable-type="LineItem"]').click
    wait_for_ajax
    expect(page).to have_content "Non-clinical Service Updated"
  end
end
