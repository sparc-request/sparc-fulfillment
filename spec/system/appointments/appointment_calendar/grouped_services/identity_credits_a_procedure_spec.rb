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

RSpec.describe 'Invoice Procedure', type: :system, js: true do

  context 'Current user is a Billing Manager with Allow Credit True' do
    let!(:sub_service_request)   { create(:sub_service_request_with_organization) }
    let!(:subsidy)               { create(:subsidy, sub_service_request: sub_service_request) }
    let!(:protocol)              { create(:protocol_imported_from_sparc, sub_service_request: sub_service_request) }
    let!(:organization_provider) { create(:organization_provider, name: "Provider") }
    let!(:organization_program)  { create(:organization_program, name: "Program", parent: organization_provider) }
    let!(:organization) do
      org = sub_service_request.organization
      org.update(parent: organization_program, name: "Core")
      org
    end

    let!(:clinical_provider) { create(:clinical_provider, identity: @logged_in_identity, organization: organization) }
    let!(:project_role_pi)   { create(:project_role_pi, identity: @logged_in_identity, protocol: protocol) }
    let!(:super_user)        { create(:super_user, identity: @logged_in_identity, organization: organization_provider, billing_manager: true, allow_credit: true) }

    let(:protocols_participant) { protocol.protocols_participants.first }
    let(:appointment)           { protocols_participant.appointments.first }
    let(:visit_group)           { appointment.visit_group }
    let(:service)               { protocol.organization.inclusive_child_services(:per_participant).first }

    scenario 'and should only see toggle button credited column' do
      given_i_am_viewing_a_visit(participant: protocols_participant, protocol: protocol)
      and_i_am_adding_a_procedure
      when_i_start_the_appointment
      then_i_should_see_the_remove_button_as_non_disabled
      when_i_complete_the_procedure
      when_i_update_the_billing_type
      then_i_should_see_the_credited_column_as_a_toggle_button
    end

    context 'a procedure has been credited' do
      scenario 'and remove button and reset button is disabled' do
        # Generates a valid DB record that physically renders, eliminating the need for the UI-addition hack
        and_i_am_viewing_completed_procedures
        then_i_should_see_the_remove_button_disabled
        then_i_should_see_the_reset_visit_button_disabled
      end
    end

    def and_i_am_viewing_completed_procedures
      appointment.update(start_date: Time.current)
      create(:procedure_insurance_billing_qty_with_notes,
             appointment: appointment,
             service: service,
             # Explicitly passing Core data to ensure the procedure renders in the UI
             sparc_core_name: service.organization.name,
             sparc_core_id: service.organization_id,
             status: 'complete',
             completed_date: Date.current.strftime('%m/%d/%Y'),
             credited: true)
             
      given_i_am_viewing_a_visit(participant: protocols_participant, protocol: protocol)
    end
  end

  context 'Current user is a Non-Billing Manager' do
    let!(:protocol)              { create_and_assign_protocol_to_me }
    let!(:protocols_participant) { protocol.protocols_participants.first }
    let!(:appointment)           { protocols_participant.appointments.first }
    let!(:visit_group)           { appointment.visit_group }
    let!(:service)               { protocol.organization.inclusive_child_services(:per_participant).first }

    scenario 'and should only see view-only credited column' do
      given_i_am_viewing_procedures_as_a_non_billing_manager
      when_i_start_the_appointment
      then_i_should_see_the_credited_column_as_view_only
    end

    def given_i_am_viewing_procedures_as_a_non_billing_manager
      given_i_am_viewing_a_visit(participant: protocols_participant, protocol: protocol)
      add_a_procedure(service: service)
    end
  end

  def and_i_am_adding_a_procedure
    add_a_procedure(service: service)
  end

  def when_i_start_the_appointment
    start_btn = find('a.btn.start-appointment, button', text: /Start (Visit|Appointment)/i, match: :first)
    start_btn.click
    
    expect(page).to have_no_css('a.btn.start-appointment')
    expect(page).to have_css('button.complete-appointment', visible: :all)
  end

  def when_i_update_the_billing_type
    row = find('tr', text: service.name, match: :first)
    
    # Grab the unique procedure ID from the DOM before we trigger the change
    proc_id = row.find('td.name div')['data-procedure-id']
    
    bootstrap_select('#procedure_billing_type', 'T', context_selector: row)
    
    # CRITICAL SYNC POINT: Wait for the server to replace the old 'R_' row with the new 'T_' row
    expect(page).to have_css("div[data-group-id^='T_'][data-procedure-id='#{proc_id}']")
  end

  def when_i_complete_the_procedure
    find('button.complete-btn', match: :first).click
    
    expect(page).to have_css('button.complete-btn.active')
  end

  def then_i_should_see_the_credited_column_as_view_only
    expect(page).to have_css('td.credited', count: 1)
    
    expect(page).to have_no_css('td.credited div.toggle')
  end

  def then_i_should_see_the_credited_column_as_a_toggle_button
    expect(page).to have_css('td.credited div.toggle:not(.disabled)', count: 1)
  end

  def then_i_should_see_the_remove_button_disabled
    expect(page).to have_css('a.delete-button.disabled, button.delete-btn:disabled, button.delete-button:disabled', visible: :all)
  end

  def then_i_should_see_the_reset_visit_button_disabled
    expect(page).to have_css('a.reset-appointment.disabled, button.reset-appointment:disabled', visible: :all)
  end

  def then_i_should_see_the_remove_button_as_non_disabled
    expect(page).to have_css('a.delete-button:not(.disabled), button.delete-btn:not(:disabled), button.delete-button:not(:disabled)', count: 1)
  end
end
