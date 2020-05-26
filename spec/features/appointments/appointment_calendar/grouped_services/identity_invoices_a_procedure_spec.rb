# Copyright © 2011-2020 MUSC Foundation for Research Development~
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

feature 'Invoice Procedure', js: true do

  context 'Current user is a Billing Manager' do
    before :each do
      given_i_am_a_billing_manager
    end

    scenario 'and should only see toggle button invoiced column' do
      and_i_am_adding_a_procedure
      then_i_shoud_see_the_invoiced_column_as_a_toggle_button
      then_i_should_see_the_remove_button_as_non_disabled
    end

    context 'a procedure has been invoiced' do
      scenario 'and remove button and reset button is disabled' do
        and_i_am_viewing_procedures
        then_i_should_see_the_remove_button_disabled
        then_i_should_see_the_reset_visit_button_disabled
      end
    end
  end

  context 'Current user is a Non-Billing Manager' do
    scenario 'and should only see view-only invoiced column' do
      given_i_am_viewing_procedures_as_a_non_billing_manager
      then_i_should_see_the_invoiced_column_as_view_only
    end
  end

  def given_i_am_a_billing_manager
    identity              = Identity.first
    sub_service_request   = create(:sub_service_request_with_organization)
    subsidy               = create(:subsidy, sub_service_request: sub_service_request)
    @protocol              = create(:protocol_imported_from_sparc, sub_service_request: sub_service_request)
    organization_provider = create(:organization_provider, name: "Provider")
    organization_program  = create(:organization_program, name: "Program", parent: organization_provider)
    organization          = sub_service_request.organization
    organization.update_attributes(parent: organization_program, name: "Core")
    create(:clinical_provider, identity: identity, organization: organization)
    create(:project_role_pi, identity: identity, protocol: @protocol)
    create(:super_user, identity: identity, organization: organization_provider, billing_manager: true)

    @protocols_participant   = @protocol.protocols_participants.first
    @visit_group   = @protocols_participant.appointments.first.visit_group
    @service       = @protocol.organization.inclusive_child_services(:per_participant).first
  end

  def and_i_am_adding_a_procedure
    visit calendar_participants_path(participant_id: @protocols_participant.participant_id, protocols_participant_id: @protocols_participant.id, protocol_id: @protocol)

    bootstrap_select('#appointment_select', @visit_group.name)
    
    bootstrap_select '#service_list', @service.name
    fill_in 'service_quantity', with: 1
    find('button.add_service').click
  end

  def and_i_am_viewing_procedures
    appointment  = @protocols_participant.appointments.first
    appointment.update_attribute(:start_date, Time.now)
    create(:procedure_insurance_billing_qty_with_notes,
            appointment: appointment,
            service: @service,
            completed_date: DateTime.current.strftime('%m/%d/%Y'),
            invoiced: true)
    visit calendar_participants_path(participant_id: @protocols_participant.participant_id, protocols_participant_id: @protocols_participant.id, protocol_id: @protocol)
    bootstrap_select('#appointment_select', @visit_group.name)
  end

  def given_i_am_viewing_procedures_as_a_non_billing_manager
    protocol      = create_and_assign_protocol_to_me
    protocols_participant   = protocol.protocols_participants.first
    visit_group   = protocols_participant.appointments.first.visit_group
    service       = protocol.organization.inclusive_child_services(:per_participant).first

    visit calendar_participants_path(participant_id: protocols_participant.participant_id, protocols_participant_id: protocols_participant.id, protocol_id: protocol)

    bootstrap_select('#appointment_select', visit_group.name)
    
    bootstrap_select '#service_list', service.name
    fill_in 'service_quantity', with: 1
    find('button.add_service').click
  end

  def then_i_should_see_the_invoiced_column_as_view_only
    expect(page).to have_css('td.invoiced_view_only', count: 1)
  end

  def then_i_shoud_see_the_invoiced_column_as_a_toggle_button
    expect(page).to have_selector('td.invoiced_toggle', count: 1)
  end

  def then_i_should_see_the_remove_button_disabled
    expect(page).to have_selector('button.reset_visit:disabled', count: 1)
  end

  def then_i_should_see_the_reset_visit_button_disabled
    expect(page).to have_selector('button.delete:disabled', count: 1)
  end

  def then_i_should_see_the_remove_button_as_non_disabled
    expect(page).to have_selector('button.delete:not(:disabled)', count: 1)
  end
    # expect(page).to have_selector("td.invoiced_toggle .toggle #invoiced_procedure[disabled]") 
    # expect(find('.toggle')).to be_disabled

    # expect(find_by_id('invoiced_procedure')).to be_disabled
    # expect(page).to have_selector('td.invoiced_toggle .toggle #invoiced_procedure:disabled', count: 1)
    # expect(page).to have_selector('div.toggle:disabled', count: 1)
end