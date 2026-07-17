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

RSpec.describe 'Identity incompletes all Services', type: :system, js: true do
  let!(:protocol)              { create(:protocol_imported_from_sparc) }
  let!(:org)                   { protocol.sub_service_request.organization }
  let!(:provider)              { create(:clinical_provider, identity: @logged_in_identity, organization: org) }
  let!(:protocols_participant) { protocol.protocols_participants.first }
  let!(:appointment)           { protocols_participant.appointments.first }
  let!(:services)              { protocol.organization.inclusive_child_services(:per_participant) }

  context 'after visit has begun' do
    before :each do
      given_i_am_viewing_a_started_visit(participant: protocols_participant, protocol: protocol)
      when_i_add_some_ungrouped_procedures
      and_i_add_some_grouped_procedures
    end

    scenario 'selects all procedures' do
      when_i_select_all_procedures_in_the_core_dropdown
      and_i_click_incomplete_all_and_give_a_reason
      and_i_unroll_accordion
      then_all_procedures_should_be_incompleted
    end

    scenario 'selects an ungrouped procedure' do
      selected = [services.first]
      when_i_select_procedures_in_the_core_dropdown(selected)
      and_i_click_incomplete_all_and_give_a_reason
      then_the_selected_procedures_should_be_incompleted(selected)
    end

    scenario 'selects multiple but not all ungrouped procedures' do
      selected = services[0..1]
      when_i_select_procedures_in_the_core_dropdown(selected)
      and_i_click_incomplete_all_and_give_a_reason
      then_the_selected_procedures_should_be_incompleted(selected)
    end

    scenario 'selects all ungrouped procedures' do
      selected = services[0..2]
      when_i_select_procedures_in_the_core_dropdown(selected)
      and_i_click_incomplete_all_and_give_a_reason
      then_the_selected_procedures_should_be_incompleted(selected)
    end

    scenario 'selects all grouped procedures' do
      selected = [services.fourth]
      when_i_select_procedures_in_the_core_dropdown(selected)
      and_i_click_incomplete_all_and_give_a_reason
      and_i_unroll_accordion
      then_the_selected_procedures_should_be_incompleted(selected)
    end
  end

  def when_i_add_some_ungrouped_procedures
    services[0..2].each do |service|
      add_a_procedure(service: service, count: 1)
    end
  end

  def and_i_add_some_grouped_procedures
    add_a_procedure(service: services.fourth, count: 2)
  end

  def when_i_select_procedures_in_the_core_dropdown(selected_services)
    # bootstrap_multiselect strict `exact_text: true` fails here due to dynamically appended UI badges, hand-roll this specific interaction using Regex for a partial text match.
    retries = 5
    begin
      find('.core_multiselect button.dropdown-toggle', match: :first).click
    rescue Selenium::WebDriver::Error::StaleElementReferenceError
      retries -= 1
      retry if retries > 0
      raise "StaleElementReferenceError exhausted targeting core multiselect"
    end

    expect(page).to have_css('.dropdown-menu.show')
    
    selected_services.each do |service|
      find('.dropdown-menu.show span.text', text: /#{Regexp.quote(service.name)}/, match: :first).click
    end
    
    find('.core_multiselect button.dropdown-toggle', match: :first).click
    
    expect(page).to have_no_css('.dropdown-menu.show')
  end

  def when_i_select_all_procedures_in_the_core_dropdown
    bootstrap_multiselect('.core_multiselect', selections: ['all'])
  end

  def and_i_click_incomplete_all_and_give_a_reason
    find('button.incomplete-all').click
    
    expect(page).to have_css('.modal-dialog', visible: true)
    
    within('.modal-content') do
      # Performer Selection (Safely hand-rolled with Regex to avoid exact text badge traps)
      find('.bootstrap-select [name="performer_id"]', visible: :hidden).ancestor('.bootstrap-select').find('.dropdown-toggle').click
      expect(page).to have_css('.dropdown-menu.show')
      find('.dropdown-menu.show span.text', text: /Sally/i, match: :first).click
      
      find('.bootstrap-select [name="reason"]', visible: :hidden).ancestor('.bootstrap-select').find('.dropdown-toggle').click
      expect(page).to have_css('.dropdown-menu.show')
      find('.dropdown-menu.show span.text', text: /#{Procedure::NOTABLE_REASONS.first}/i, match: :first).click
      
      fill_in 'comment', with: 'Test comment'
      
      # Target natively to support both input[type="submit"] and button tags
      click_button 'Submit'
    end
    
    expect(page).to have_no_css('.modal-dialog')
  end

  def and_i_unroll_accordion
    while page.has_css?('tr.groupBy.expanded', wait: 0.5)
      find('tr.groupBy.expanded', match: :first).click
    end
    
    expect(page).to have_no_css('tr.groupBy.expanded')
  end

  def then_the_selected_procedures_should_be_incompleted(selected_services)
    expect(page).to have_css('button.incomplete-btn.active', minimum: 1)

    selected_procedures = Procedure.where(service_id: selected_services.map(&:id))
    unselected_procedures = Procedure.where.not(service_id: selected_services.map(&:id))

    selected_procedures.each do |procedure|
      expect(procedure.status).to eq('incomplete')
    end

    unselected_procedures.each do |procedure|
      expect(procedure.status).to eq('unstarted')
    end
  end

  def then_all_procedures_should_be_incompleted
    expect(page).to have_css('button.incomplete-btn.active', minimum: 1)
    
    Procedure.all.each do |procedure|
      expect(procedure.status).to eq('incomplete')
    end
  end
end
