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

  context 'Current user is a Billing Manager with Allow Credit True' do
    before :each do
      given_i_am_a_billing_manager
    end

    scenario 'and should only see toggle button credited column' do
      and_i_am_viewing_uncompleted_procedures
      and_i_am_adding_a_procedure
      when_i_start_the_appointment
      then_i_should_see_the_remove_button_as_non_disabled
      when_i_complete_the_procedure
      when_i_update_the_billing_type
      then_i_should_see_the_credited_column_as_a_toggle_button
    end

    context 'a procedure has been credited' do
      scenario 'and remove button and reset button is disabled' do
        and_i_am_viewing_completed_procedures
        and_i_am_adding_a_procedure
        then_i_should_see_the_remove_button_disabled
        then_i_should_see_the_reset_visit_button_disabled
      end
    end
  end

  context 'Current user is a Non-Billing Manager' do
    scenario 'and should only see view-only credited column' do
      given_i_am_viewing_procedures_as_a_non_billing_manager
      when_i_start_the_appointment  
      then_i_should_see_the_credited_column_as_view_only
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
    create(:super_user, identity: identity, organization: organization_provider, billing_manager: true, allow_credit: true)

    @protocols_participant   = @protocol.protocols_participants.first
    @visit_group   = @protocols_participant.appointments.first.visit_group
    @service       = @protocol.organization.inclusive_child_services(:per_participant).first
  end

  def given_i_am_viewing_procedures_as_a_non_billing_manager
    protocol      = create_and_assign_protocol_to_me
    protocols_participant   = protocol.protocols_participants.first
    visit_group   = protocols_participant.appointments.first.visit_group
    @service       = protocol.organization.inclusive_child_services(:per_participant).first

    visit calendar_protocol_participant_path(id: protocols_participant.id, protocol_id: protocol)

    page.find('a.list-group-item[data-appointment-id="1"]').click
    bootstrap_select '[name="service_id"]', @service.name
    fill_in 'service_quantity', with: 1
    find('button#addService').click
  end

  def and_i_am_adding_a_procedure
    page.find('a.list-group-item[data-appointment-id="1"]').click
    bootstrap_select '[name="service_id"]', @service.name
    fill_in 'service_quantity', with: 1
    find('button#addService').click
  end

  def and_i_am_viewing_uncompleted_procedures
    appointment  = @protocols_participant.appointments.first
    create(:procedure_insurance_billing_qty_with_notes,
            appointment: appointment,
            service: @service,
            credited: true)
    visit calendar_protocol_participant_path(id: @protocols_participant.id, protocol_id: @protocol)
  end

  def and_i_am_viewing_completed_procedures
    appointment  = @protocols_participant.appointments.first
    appointment.update_attribute(:start_date, Time.now)
    create(:procedure_insurance_billing_qty_with_notes,
            appointment: appointment,
            service: @service,
            completed_date: DateTime.current.strftime('%m/%d/%Y'),
            credited: true)
    visit calendar_protocol_participant_path(id: @protocols_participant.id, protocol_id: @protocol)
  end

  def when_i_start_the_appointment
    find('a.btn.start-appointment').click
    wait_for_ajax
  end

  def when_i_update_the_billing_type
    bootstrap_select '#procedure_billing_type', 'T'
  end

  def when_i_complete_the_procedure
    find('button.complete-btn').click
  end
  
  def then_i_should_see_the_credited_column_as_view_only
    expect(page).to have_css('td.credited', count: 1)
  end

  def then_i_should_see_the_credited_column_as_a_toggle_button
    expect(page).to_not have_selector('td.w-5.credited div.toggle.btn-light.disabled', count: 1)
  end

  def then_i_should_see_the_remove_button_disabled
    expect(page).to have_selector('a.reset-appointment.disabled', count: 1)
  end

  def then_i_should_see_the_reset_visit_button_disabled
    expect(page).to have_selector('a.reset-appointment.disabled', count: 1)
  end

  def then_i_should_see_the_remove_button_as_non_disabled
    expect(page).to have_selector('a.delete-button:not(:disabled)', count: 1)
  end
end
