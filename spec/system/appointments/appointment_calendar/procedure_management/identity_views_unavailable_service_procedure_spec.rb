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

RSpec.describe 'Identity views procedure which has an unavailable service', type: :system, js: true do
  # VI. The RSpec Execution Trap: Lazy evaluation ONLY. No let! blocks here.
  let(:protocol)              { create_and_assign_protocol_to_me }
  let(:protocols_participant) { protocol.protocols_participants.first }
  let(:appointment)           { protocols_participant.appointments.first }
  let(:services)              { protocol.organization.inclusive_child_services(:per_participant) }
  let(:first_service)         { services.first }

  let(:inactive_core)         { create(:organization, type: 'Core', name: 'Test Core') }
  let(:inactive_service)      { create(:service, organization: inactive_core) }
  let(:inactive_procedure) do
    create(
      :procedure,
      appointment: appointment,
      service: inactive_service,
      service_name: inactive_service.name,
      sparc_core_id: inactive_core.id,
      sparc_core_name: inactive_core.name,
      status: 'unstarted'
    )
  end

  scenario 'and sees the inactive tag' do
    given_i_have_added_a_procedure(service: first_service)
    when_the_procedure_is_complete(service: first_service)
    when_i_change_the_service_to_inactive(service: first_service)
    
    when_i_open_the_appointment_calendar
    then_i_should_see_the_inactive_tag(service: first_service)
  end

  scenario 'and procedure is unstarted' do
    given_i_have_added_a_procedure(service: first_service)
    when_i_change_the_service_to_inactive(service: first_service)
    
    when_i_open_the_appointment_calendar
    then_i_should_not_see_the_procedure(service: first_service)
  end

  scenario 'and core with only unstarted unavailable services is hidden' do
    given_i_have_an_unstarted_procedure_in_a_new_core
    when_i_change_the_service_to_inactive(service: inactive_service)
    
    when_i_open_the_appointment_calendar
    then_i_should_not_see_the_procedure(service: inactive_service)
    then_i_should_not_see_the_core(core: inactive_core)

    when_i_make_the_procedure_incomplete
    when_i_open_the_appointment_calendar
    
    then_i_should_see_the_procedure(service: inactive_service)
    then_i_should_see_the_core(core: inactive_core)
  end

  def given_i_have_added_a_procedure(service:)
    given_i_am_viewing_a_visit(participant: protocols_participant, protocol: protocol)
    add_a_procedure(service: service)
  end

  def given_i_have_an_unstarted_procedure_in_a_new_core
    # Simply calling the lazy let block instantiates it in the database exactly when needed
    inactive_procedure
  end

  def when_the_procedure_is_complete(service:)
    # Bypassing the UI here to quickly arrange database state
    procedure = appointment.procedures.find_by(service_id: service.id)
    procedure.update(status: 'complete')
  end

  def when_i_make_the_procedure_incomplete
    inactive_procedure.update(status: 'incomplete')
  end

  def when_i_change_the_service_to_inactive(service:)
    service.update(is_available: false)
  end

  def when_i_open_the_appointment_calendar
    visit calendar_protocol_participant_path(id: protocols_participant.id, protocol_id: protocol.id)
    
    # Native sync point to replace wait_for_ajax: ensuring the core container renders
    expect(page).to have_css('#appointmentContainer', visible: :all)
  end

  def then_i_should_see_the_inactive_tag(service:)
    within('tr', text: /#{Regexp.quote(service.name)}/, match: :first) do
      expect(page).to have_text('(Inactive)')
    end
  end

  def then_i_should_not_see_the_procedure(service:)
    # Because we are asserting the ABSENCE of something, we must first assert 
    # the PRESENCE of the parent wrapper to avoid a false positive while the page loads!
    expect(page).to have_css('.list-group-item.appointment-link')
    expect(page).to have_no_css('tr', text: /#{Regexp.quote(service.name)}/, visible: :all)
  end

  def then_i_should_see_the_procedure(service:)
    expect(page).to have_css('tr', text: /#{Regexp.quote(service.name)}/, visible: :all)
    
    within('tr', text: /#{Regexp.quote(service.name)}/, match: :first) do
      expect(page).to have_text('(Inactive)')
    end
  end

  def then_i_should_not_see_the_core(core:)
    expect(page).to have_no_content(core.name)
  end

  def then_i_should_see_the_core(core:)
    expect(page).to have_content(core.name)
  end
end
