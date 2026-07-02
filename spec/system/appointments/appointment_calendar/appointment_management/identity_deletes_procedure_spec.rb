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

RSpec.describe 'Delete Procedure', type: :system, js: true do
  let(:protocol) { create_and_assign_protocol_to_me(identity: @logged_in_identity) }
  let(:protocols_participant) { protocol.protocols_participants.first }
  let(:visit_group) { protocols_participant.appointments.first.visit_group }
  let(:service) { protocol.organization.inclusive_child_services(:per_participant).first }

  context 'User deletes a core' do
    scenario 'and does not see the core' do
      given_i_am_viewing_a_core_with_n_procedures_such_that_n_is '1'
      when_i_begin_the_appointment
      when_i_delete_the_first_procedure
      then_i_should_not_see_the_core
    end
  end

  context 'User deletes a procedure but not a core' do
    scenario 'and does not see the procedure' do
      given_i_am_viewing_a_core_with_n_procedures_such_that_n_is '2'
      when_i_begin_the_appointment
      and_i_unroll_the_group
      when_i_delete_the_first_procedure
      then_i_should_not_see_the_first_procedure
    end
  end

  def given_i_am_viewing_a_core_with_n_procedures_such_that_n_is(number_of_procedures)
    visit calendar_protocol_participant_path(id: protocols_participant.id, protocol_id: protocol.id)

    find('a.list-group-item.appointment-link', text: visit_group.name, match: :first).click

    within('#appointmentContainer') do
      expect(page).to have_css('h3', text: /#{visit_group.name}/i)
    end

    bootstrap_select('.form-control.selectpicker', service.name)
    
    fill_in 'service_quantity', with: number_of_procedures
    click_button 'Add Service' 

    within('#appointmentContainer') do
      expect(page).to have_css('tr', text: service.name)
    end
  end

  def when_i_begin_the_appointment
    click_link 'Start Visit'
    expect(page).to have_no_link('Start Visit')

    find('a.list-group-item, a.visit-group-link', text: visit_group.name, match: :first).click
    
    within('#appointmentContainer') do
      expect(page).to have_css('h3', text: /#{visit_group.name}/i)
    end
  end

  def when_i_delete_the_first_procedure
    # Using match: :first forces Capybara to wait for the unroll animation to reveal the button.
    within('#appointmentContainer') do
      find('.btn-danger, button.delete', match: :first).click
    end

    within('.swal2-container') do
      find('button.swal2-confirm').click
    end

    expect(page).to have_no_css('.swal2-container')
  end

  def and_i_unroll_the_group
    first('#appointmentContainer tr.groupBy').click
  end

  def then_i_should_not_see_the_core
    within('#appointmentContainer') do
      expect(page).to have_no_css('tr', text: service.name)
    end
  end

  def then_i_should_not_see_the_first_procedure
    within('#appointmentContainer') do
      expect(page).to have_css('tr', text: service.name, count: 1)
    end
  end
end
