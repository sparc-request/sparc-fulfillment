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

RSpec.describe 'User adds a Procedure to an unstarted visit', type: :system, js: true do
  let!(:protocol)               { create_and_assign_protocol_to_me }
  let!(:protocols_participant)  { protocol.protocols_participants.first }
  let!(:appointment)            { protocols_participant.appointments.first }
  let!(:services)               { protocol.organization.inclusive_child_services(:per_participant) }

  let(:first_service) { services.first }

  scenario 'and sees that a core has been created' do
    given_i_am_viewing_a_visit(participant: protocols_participant, protocol: protocol)
    when_i_add_two_procedures_to_the_same_group
    then_i_should_see_a_new_core_created
  end 

  scenario 'and sees that the entire multiselect dropdown is disabled' do
    given_i_am_viewing_a_visit(participant: protocols_participant, protocol: protocol)
    when_i_add_two_procedures_to_the_same_group
    then_i_should_see_that_the_multiselect_dropdown_is_disabled
  end

  scenario 'and sees that the incomplete button is disabled' do
    given_i_am_viewing_a_visit(participant: protocols_participant, protocol: protocol)
    when_i_add_two_procedures_to_the_same_group
    then_i_should_see_that_the_incomplete_button_is_disabled
  end

  scenario 'and sees that the complete button is disabled' do
    given_i_am_viewing_a_visit(participant: protocols_participant, protocol: protocol)
    when_i_add_two_procedures_to_the_same_group
    then_i_should_see_that_the_complete_button_is_disabled
  end

  def when_i_add_two_procedures_to_the_same_group
    add_a_procedure(service: first_service, count: 2)
  end

  def then_i_should_see_a_new_core_created
    expect(page).to have_css('.core')
  end

  def then_i_should_see_that_the_multiselect_dropdown_is_disabled
    expect(page).to have_css('button.multiselect.disabled')
  end

  def then_i_should_see_that_the_incomplete_button_is_disabled
    expect(page).to have_css('button.complete-all.disabled')
  end

  def then_i_should_see_that_the_complete_button_is_disabled
    expect(page).to have_css('button.incomplete-all.disabled')
  end
end
