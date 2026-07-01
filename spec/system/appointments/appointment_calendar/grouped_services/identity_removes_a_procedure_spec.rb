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

RSpec.describe 'Identity removes a Procedure', type: :system, js: true do
  let(:protocol)              { create_and_assign_protocol_to_me }
  let(:protocols_participant) { protocol.protocols_participants.first }
  let(:appointment)           { protocols_participant.appointments.first }
  let(:services)              { protocol.organization.inclusive_child_services(:per_participant) }

  let(:first_service) { services.first }

  context 'when group has more than 3 members' do
    before :each do
      given_i_am_viewing_a_visit(participant: protocols_participant, protocol: protocol)
      when_i_start_the_appointment
      when_i_add_3_procedures_to_same_group
    end

    scenario 'and no longer sees the Procedure' do
      when_i_remove_the_first_procedure
      then_i_should_no_longer_see_that_procedure
    end

    scenario 'and sees the group counter decremented' do
      when_i_remove_the_first_procedure
      then_i_should_see_the_group_counter_decrement_by_1
    end
  end

  context 'when group has 2 members' do
    before :each do
      given_i_am_viewing_a_visit(participant: protocols_participant, protocol: protocol)
      when_i_start_the_appointment
      when_i_add_2_procedures_to_same_group
    end

    scenario 'and no longer sees the group' do
      when_i_remove_the_first_procedure
      then_i_should_no_longer_see_the_group
    end
  end

  def when_i_start_the_appointment
    find('a.btn.start-appointment, button', text: /Start (Visit|Appointment)/i, match: :first).click
    
    expect(page).to have_no_css('a.btn.start-appointment')
    expect(page).to have_css('button.complete-appointment', visible: :all)
  end

  def when_i_add_3_procedures_to_same_group
    add_a_procedure(service: first_service, count: 3)
  end

  def when_i_add_2_procedures_to_same_group
    add_a_procedure(service: first_service, count: 2)
  end

  def when_i_remove_the_first_procedure
    # Safely unroll the accordion, accounting for the app's inverse 'expanded' logic
    while page.has_css?('tr.groupBy.expanded', wait: 0.5)
      find('tr.groupBy.expanded', match: :first).click
    end
    expect(page).to have_no_css('tr.groupBy.expanded')

    # Natively verify the correct amount of delete buttons exist before clicking one
    previous_count = all('a.delete-button, button.delete-btn', visible: true).count

    find('a.delete-button, button.delete-btn', match: :first).click

    # Natively anticipate the SweetAlert2 modal to fade in
    expect(page).to have_css('.swal2-container', visible: true)
    find('button.swal2-confirm').click

    expect(page).to have_no_css('.swal2-container')
    
    # Since the UI auto-closes the accordion after a delete, use 'visible: :all'
    expect(page).to have_css('a.delete-button, button.delete-btn', count: previous_count - 1, visible: :all)
  end

  def then_i_should_no_longer_see_that_procedure
    # Since the UI is strictly synced in 'when_i_remove_the_first_procedure', we safely assert final state
    expect(page).to have_css('tr[data-parent-index="0"]', count: 2, visible: :all)
  end

  def then_i_should_see_the_group_counter_decrement_by_1
    expect(page).to have_css('tr.groupBy strong.badge', text: '2')
  end

  def then_i_should_no_longer_see_the_group
    expect(page).to have_no_css('tr.groupBy')
  end
end
