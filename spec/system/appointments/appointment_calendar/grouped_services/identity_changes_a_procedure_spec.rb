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

RSpec.describe 'Identity changes a Service', type: :system, js: true do
  let!(:protocol)              { create(:protocol_imported_from_sparc) }
  let!(:org)                   { protocol.sub_service_request.organization }
  let!(:provider)              { create(:clinical_provider, identity: @logged_in_identity, organization: org) }
  
  let!(:protocols_participant) { protocol.protocols_participants.first }
  let!(:appointment)           { protocols_participant.appointments.first }
  let!(:services)              { protocol.organization.inclusive_child_services(:per_participant) }

  let(:first_service) { services.first }
  let(:second_service) { services.last }

  scenario 'and sees it join an existing group' do
    given_i_am_viewing_a_visit_with_one_procedure_group
    and_the_visit_has_one_ungrouped_procedure
    when_i_start_the_appointment
    when_i_change_the_ungrouped_procedure_to_match_the_grouped_procedures
    then_i_should_see_the_procedure_in_the_group
    then_i_should_see_the_procedure_group_counter_is_four
  end

  scenario 'and sees it is not longer in its original group' do
    given_i_am_viewing_a_visit_with_one_procedure_group
    when_i_start_the_appointment
    when_i_change_a_grouped_procedure_to_not_match_the_group
    then_i_should_not_see_the_procedure_in_the_group
  end

  scenario 'and no longer sees the original group' do
    given_i_am_viewing_a_visit_with_one_procedure_group
    when_i_start_the_appointment
    when_i_move_all_procedures_out_of_the_group
    then_i_should_not_see_the_procedure_group
  end

  scenario 'and sees the Service is a member of a new group' do
    given_i_am_viewing_a_visit_with_two_procedures_with_different_billing_types
    when_i_start_the_appointment
    when_i_change_one_procedure_billing_type_to_be_the_same_as_the_other
    then_i_should_see_one_procedure_group
  end

  scenario 'and sees the Service counter of the original group has been decremented' do
    given_i_am_viewing_a_visit_with_one_procedure_group
    when_i_start_the_appointment
    when_i_change_a_grouped_procedure_to_not_match_the_group
    then_i_should_see_the_procedure_group_counter_is_two
  end

  def given_i_am_viewing_a_visit(participant:, protocol:)
    visit calendar_protocol_participant_path(id: participant.id, protocol_id: protocol.id)
    
    expect(page).to have_css('#appointmentContainer', visible: :all)
    expect(page).to have_css('a.list-group-item.appointment-link')
    
    retries = 3
    begin
      first('a.list-group-item.appointment-link').click
    rescue Selenium::WebDriver::Error::StaleElementReferenceError
      retries -= 1
      retry if retries > 0
    end
    
    expect(page).to have_button('addService', disabled: :all)
  end

  def given_i_am_viewing_a_visit_with_two_procedures_with_different_billing_types
    create(:procedure_insurance_billing_qty_with_notes,
            appointment: appointment,
            service: first_service,
            sparc_core_name: first_service.organization.name,
            sparc_core_id: first_service.organization_id)

    create(:procedure_research_billing_qty_with_notes,
            appointment: appointment,
            service: first_service,
            sparc_core_name: first_service.organization.name,
            sparc_core_id: first_service.organization_id)

    given_i_am_viewing_a_visit(participant: protocols_participant, protocol: protocol)
  end

  def given_i_am_viewing_a_visit_with_one_procedure_group
    create_list(:procedure_insurance_billing_qty_with_notes, 3,
                appointment: appointment,
                service: first_service,
                sparc_core_name: first_service.organization.name,
                sparc_core_id: first_service.organization_id)

    given_i_am_viewing_a_visit(participant: protocols_participant, protocol: protocol)
  end

  def when_i_start_the_appointment
    start_btn = find('a.btn.start-appointment, button', text: /Start (Visit|Appointment)/i, match: :first)
    start_btn.click
    
    expect(page).to have_no_css('a.btn.start-appointment')
    expect(page).to have_css('button.complete-appointment', visible: :all)
  end

  def and_the_visit_has_one_ungrouped_procedure
    add_a_procedure(service: first_service)
  end

  def ungrouped_procedure_record
    expect(page).to have_css("tr", text: first_service.name, minimum: 4, visible: :all)
    Procedure.order(:id).last
  end

  def when_i_change_one_procedure_billing_type_to_be_the_same_as_the_other
    row = first("button[title='R']").ancestor('tr')
    bootstrap_select('#procedure_billing_type', 'T', context_selector: row)
  end

  def when_i_move_all_procedures_out_of_the_group
    @original_group_id = first('tr td.name div', visible: :all)['data-group-id']
    
    3.times do |i|
      # Click ANY closed groups to ensure rows are visible, and cleanly wait for the animation
      # Also... there is inverse logic here within the application... the 'expanded' class is applied when the accordion is closed and vice versa
      all('tr.groupBy.expanded').each { |closed_group| closed_group.click }
      expect(page).to have_no_css('tr.groupBy.expanded')

      # Target by the visible 'T' title safely, dodging dynamic group IDs entirely
      row = first("button[title='T']", visible: true).ancestor('tr')
      bootstrap_select('#procedure_billing_type', 'R', context_selector: row)
      
      # Crucial Sync: natively wait for the total count of 'T' items to decrement
      if i < 2
        expect(page).to have_css("button[title='T']", count: 2 - i, visible: :all)
      else
        expect(page).to have_no_css("button[title='T']", visible: :all)
      end
    end
  end

  def when_i_change_a_grouped_procedure_to_not_match_the_group
    all('tr.groupBy.expanded').each { |closed_group| closed_group.click }
    expect(page).to have_no_css('tr.groupBy.expanded')

    # Use the visible 'T' title to safely target a grouped row, dodging internal indices entirely
    row = first("button[title='T']", visible: true).ancestor('tr')
    bootstrap_select('#procedure_billing_type', 'R', context_selector: row)
    
    # Natively wait for the badge to recalculate
    expect(page).to have_css('tr.groupBy strong.badge', text: '2')
  end

  def when_i_change_the_ungrouped_procedure_to_match_the_grouped_procedures
    row = first("form#edit_procedure_#{ungrouped_procedure_record.id}").ancestor('tr')
    bootstrap_select('#procedure_billing_type', 'T', context_selector: row)
  end

  def then_i_should_see_the_procedure_group_counter_is_two
    expect(page).to have_css('tr.groupBy strong.badge', text: '2')
  end

  def then_i_should_see_the_procedure_group_counter_is_four
    expect(page).to have_css('tr.groupBy strong.badge', text: '4')
  end

  def then_i_should_see_one_procedure_group
    expect(page).to have_css('tr.expanded.groupBy', count: 1)
  end

  def then_i_should_not_see_the_procedure_group
    expect(page).to_not have_css("div[data-group-id='#{@original_group_id}']")
  end

  def then_i_should_not_see_the_procedure_in_the_group
    # Asserting exactly 1 'R' (the ungrouped item) and exactly 2 'T' (the remaining group)
    expect(page).to have_css('tr.groupBy strong.badge', text: '2')
    expect(page).to have_css("button[title='R']", count: 1)
  end

  def then_i_should_see_the_procedure_in_the_group
    expect(page).to have_css('tr.groupBy strong.badge', text: '4')
  end
end
