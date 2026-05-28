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

RSpec.describe 'Identity adds multiple Procedures', type: :system, js: true do
  let!(:protocol)              { create_and_assign_protocol_to_me }
  let!(:protocols_participant) { protocol.protocols_participants.first }
  let!(:appointment)           { protocols_participant.appointments.first }
  let!(:services)              { protocol.organization.inclusive_child_services(:per_participant) }

  let(:first_service)  { services.first }
  let(:second_service) { services.last }

  scenario 'which are not part of an existing group' do
    given_i_am_viewing_a_visit(participant: protocols_participant, protocol: protocol)
    and_the_visit_has_one_grouped_procedure(service: first_service)
    when_i_add_two_different_procedures
    then_i_should_see_two_grouped_procedures
  end

  scenario 'which are part of an existing Service group' do
    given_i_am_viewing_a_visit(participant: protocols_participant, protocol: protocol)
    and_the_visit_has_one_grouped_procedure(service: first_service)
    when_i_add_two_similar_procedures
    then_i_should_see_one_group_with_four_procedures
  end

  scenario 'and sees the multiselect dropdown instantiated with Select All option and Service option' do
    given_i_am_viewing_a_started_visit(participant: protocols_participant, protocol: protocol)
    when_i_add_5_procedures
    then_i_should_see_the_multiselect_instantiated_with_options
  end

  def when_i_add_two_similar_procedures
    add_a_procedure(service: first_service, count: 2)
  end

  def when_i_add_two_different_procedures
    add_a_procedure(service: second_service, count: 2)
  end

  def when_i_add_5_procedures
    add_a_procedure(service: first_service, count: 5)
  end

  def then_i_should_see_the_multiselect_instantiated_with_options
    # Wait for the DOM to natively group the elements first by checking the badge
    expect(page).to have_css('tr.groupBy strong.badge', text: '5')

    # Safely target the UI natively without querying the DB for dynamic DOM IDs
    find('.core_multiselect button.dropdown-toggle', match: :first).click
    
    # Wait for animations natively
    expect(page).to have_css('.dropdown-menu.show')

    expect(page).to have_css('button.bs-select-all')
    expect(page).to have_content(first_service.name)
  end

  def then_i_should_see_one_group_with_four_procedures
    expect(page).to have_css('tr.groupBy strong.badge', text: '4')
    expect(page).to have_css('tr.groupBy', count: 1)
  end

  def then_i_should_see_two_grouped_procedures
    # Replaced the leaky accordion 'expanded' state check with a strict count of group rows
    expect(page).to have_css('tr.groupBy', count: 2)
    
    # Verify both groups accurately reflect their 2 items
    expect(page).to have_css('tr.groupBy strong.badge', text: '2', count: 2)
  end
end
