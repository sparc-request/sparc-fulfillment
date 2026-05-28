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

RSpec.describe 'Identity completes all Services', type: :system, js: true do

  let!(:protocol)              { create_and_assign_protocol_to_me }
  let!(:protocols_participant) { protocol.protocols_participants.first }
  let!(:appointment)           { protocols_participant.appointments.first }
  let!(:services)              { protocol.organization.inclusive_child_services(:per_participant) }

  let(:first_service)  { services.first }
  let(:second_service) { services.last }

  context 'in a Core with a ungrouped procedure and grouped procedures' do
    before :each do
      given_i_am_viewing_a_started_visit(participant: protocols_participant, protocol: protocol)
      when_i_add_a_grouped_procedure_and_ungrouped_procedure
    end

    scenario 'and sees that all selected Procedures are completed' do
      and_i_select_the_procedure_in_the_core_dropdown
      and_i_click_complete_all
      then_i_should_see_a_complete_all_modal
      with_a_default_completed_date_of_current_date
      when_i_fill_in_performed_by
      when_i_save_the_modal
      then_i_should_see_all_selected_procedures_completed
    end

    scenario 'and sees that all Procedures are completed' do
      and_i_select_all_in_the_core_dropdown
      and_i_click_complete_all
      then_i_should_see_a_complete_all_modal
      when_i_fill_in_performed_by
      when_i_save_the_modal
      then_i_should_see_all_procedures_completed
    end 
  end

  def when_i_add_a_grouped_procedure_and_ungrouped_procedure
    add_a_procedure(service: first_service, count: 1)
    add_a_procedure(service: second_service, count: 2)
  end

  def and_i_select_the_procedure_in_the_core_dropdown
    # bootstrap_multiselect uses strict `exact_text: true` requirement, which fails here because the UI dynamically appends a billing type badge to the text, which Capybara squashes together.
    # Using Regex for a partial text match
    retries = 5
    begin
      find('.core_multiselect button.dropdown-toggle', match: :first).click
    rescue Selenium::WebDriver::Error::StaleElementReferenceError
      retries -= 1
      retry if retries > 0
      raise "StaleElementReferenceError exhausted targeting core multiselect"
    end

    expect(page).to have_css('.dropdown-menu.show')
    
    # Match the service name natively using Regex, ignoring the squashed 'R' or 'T' badge at the end
    find('.dropdown-menu.show span.text', text: /#{Regexp.quote(second_service.name)}/, match: :first).click
    
    find('.core_multiselect button.dropdown-toggle', match: :first).click

    expect(page).to have_no_css('.dropdown-menu.show')
  end

  def and_i_click_complete_all
    find('button.complete-all').click
  end

  def then_i_should_see_a_complete_all_modal
    expect(page).to have_css('.modal-dialog', visible: true)
    
    within('.modal-content') do
      expect(page).to have_text("Complete Multiple Services")
    end
  end

  def with_a_default_completed_date_of_current_date
    within('.modal-content') do
      input = find('.datetimepicker-input', visible: :all)
      expect(input.value).to eq(DateTime.current.strftime('%m/%d/%Y'))
    end
  end

  def when_i_fill_in_performed_by
    within('.modal-content') do
      # Safely target the toggle without node-trapping
      find('.bootstrap-select [name="performer_id"]', visible: :hidden).ancestor('.bootstrap-select').find('.dropdown-toggle').click
      expect(page).to have_css('.dropdown-menu.show')
      
      # Use match: :first and Regex to dodge exact text limitations of the global helper
      find('.dropdown-menu.show span.text', text: /Sally/i, match: :first).click
    end
  end

  def when_i_save_the_modal
    within('.modal-content') do
      click_button 'Submit'
    end
    expect(page).to have_no_css('.modal-dialog')
  end

  def and_i_select_all_in_the_core_dropdown
    # Leveraging the global helper to natively select all
    bootstrap_multiselect('.core_multiselect', selections: ['all'])
  end

  def then_i_should_see_all_selected_procedures_completed
    while page.has_css?('tr.groupBy.expanded', wait: 0.5)
      find('tr.groupBy.expanded', match: :first).click
    end

    expect(page).to have_no_css('tr.groupBy.expanded')
    expect(page).to have_css('tr[data-parent-index="0"]', visible: true)

    expect(page).to have_css('button.complete-btn.active', count: 2)
  end

  def then_i_should_see_all_procedures_completed
    while page.has_css?('tr.groupBy.expanded', wait: 0.5)
      find('tr.groupBy.expanded', match: :first).click
    end

    expect(page).to have_no_css('tr.groupBy.expanded')
    expect(page).to have_css('tr[data-parent-index="0"]', visible: true)

    expect(page).to have_css('button.complete-btn.active', count: 3)

    expect(Procedure.where(service_id: second_service.id).first.status).to eq("complete")
    expect(Procedure.where(service_id: second_service.id).last.status).to eq("complete")
    expect(Procedure.where(service_id: first_service.id).last.status).to eq("complete")
  end
end
