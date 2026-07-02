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

RSpec.describe 'Identity adds a Procedure', type: :system, js: true do
  let(:protocol)              { create_and_assign_protocol_to_me }
  let(:protocols_participant) { protocol.protocols_participants.first }
  let(:appointment)           { protocols_participant.appointments.first }
  let(:services)              { protocol.organization.inclusive_child_services(:per_participant) }
  
  let(:first_service)  { services.first }
  let(:second_service) { services.last }

  scenario 'and sees the procedure in the correct Core' do
    given_i_am_viewing_a_visit(participant: protocols_participant, protocol: protocol)
    when_i_add_a_procedure
    then_i_should_see_a_core
  end

  scenario 'and sees the multiselect dropdown instantiated with Select All option and Procedure option' do
    given_i_am_viewing_a_started_visit(participant: protocols_participant, protocol: protocol)
    when_i_add_a_procedure
    then_i_should_see_the_multiselect_instantiated_with_options
  end

  scenario 'and sees that the Complete and Incomplete buttons on the multiselect are enabled when a Service has been selected' do
    given_i_am_viewing_a_started_visit(participant: protocols_participant, protocol: protocol)
    when_i_add_a_procedure
    and_select_a_procedure_from_multiselect
    then_i_should_see_enabled_complete_and_incomplete_buttons
  end

  scenario 'and sees that the Complete and Incomplete buttons on the multiselect are enabled when all Services have been selected' do
    given_i_am_viewing_a_started_visit(participant: protocols_participant, protocol: protocol)
    when_i_add_a_procedure
    when_i_add_a_different_procedure
    and_select_all_procedures_from_multiselect
    then_i_should_see_enabled_complete_and_incomplete_buttons
  end

  scenario 'which is part of an existing group and sees the Procedure in a group' do
    given_i_am_viewing_a_visit(participant: protocols_participant, protocol: protocol)
    and_the_visit_has_one_grouped_procedure
    when_i_add_a_similar_procedure
    then_i_should_see_three_procedures_in_the_group
  end

  scenario 'and sees the quantity increment for the group in the multiselect dropdown' do
    given_i_am_viewing_a_started_visit(participant: protocols_participant, protocol: protocol)
    and_the_visit_has_one_grouped_procedure
    when_i_add_a_similar_procedure
    then_i_should_see_the_quantity_increment_for_the_group_in_the_multiselect_dropdown
  end

  scenario 'which is not part of a group and does not see the Procedure in a group' do
    given_i_am_viewing_a_visit(participant: protocols_participant, protocol: protocol)
    and_the_visit_has_one_grouped_procedure
    when_i_add_a_different_procedure
    then_i_should_not_see_the_procedure_in_the_group
  end

  scenario 'which is not part of an existing group and sees a Procedure group created' do
    given_i_am_viewing_a_visit(participant: protocols_participant, protocol: protocol)
    and_the_visit_has_one_procedure
    when_i_add_a_similar_procedure
    then_i_should_see_two_procedures_in_the_group
  end

  scenario 'which is part of an existing group and sees the group counter incremented' do
    given_i_am_viewing_a_visit(participant: protocols_participant, protocol: protocol)
    and_the_visit_has_one_grouped_procedure
    when_i_add_a_similar_procedure
    then_i_should_see_the_group_counter_is_correct
  end

  def when_i_add_a_procedure
    add_a_procedure(service: first_service)
  end

  def when_i_add_a_different_procedure
    add_a_procedure(service: second_service)
  end

  def and_the_visit_has_one_grouped_procedure
    add_a_procedure(service: first_service, count: 2)
  end

  def then_i_should_see_the_group_counter_is_correct
    expect(page).to have_css('tr.groupBy strong.badge', text: '3')
  end

  def and_select_a_procedure_from_multiselect
    # Safely hand-rolling the single procedure selection to bypass dynamic exact_text badge matches and eradicating the legacy practice of querying the DB for DOM IDs
    find('.core_multiselect button.dropdown-toggle', match: :first).click
    expect(page).to have_css('.dropdown-menu.show')
    
    find('.dropdown-menu.show span.text', text: /#{Regexp.quote(first_service.name)}/, match: :first).click
    
    # Close the menu to ensure complete/incomplete buttons are fully interactable
    find('.core_multiselect button.dropdown-toggle', match: :first).click
    expect(page).to have_no_css('.dropdown-menu.show')
  end

  def and_select_all_procedures_from_multiselect
    bootstrap_multiselect('.core_multiselect', selections: ['all'])
  end

  def then_i_should_see_enabled_complete_and_incomplete_buttons
    expect(page).to have_css('button.complete_all:not(.disabled), button.complete-all:not(.disabled)')
    expect(page).to have_css('button.incomplete_all:not(.disabled), button.incomplete-all:not(.disabled)')
  end

  def then_i_should_not_see_the_procedure_in_the_group
    expect(page).to have_css('tr.groupBy strong.badge', text: '2')
    
    expect(page).to have_css('tr', text: second_service.name)
    expect(page).to have_no_css('tr.groupBy', text: /#{Regexp.quote(second_service.name)}/)
  end

  def then_i_should_see_two_procedures_in_the_group
    expect(page).to have_css('tr.groupBy strong.badge', text: '2')
  end

  def then_i_should_see_three_procedures_in_the_group
    expect(page).to have_css('tr.groupBy strong.badge', text: '3')
  end

  def then_i_should_see_a_core
    expect(page).to have_css('.core, .core_multiselect', visible: :all)
  end

  def then_i_should_see_the_multiselect_instantiated_with_options
    find('.core_multiselect button.dropdown-toggle', match: :first).click
    expect(page).to have_css('.dropdown-menu.show')

    expect(page).to have_css('button.bs-select-all')
    expect(page).to have_content(first_service.name)
  end

  def then_i_should_see_the_quantity_increment_for_the_group_in_the_multiselect_dropdown
    find('.core_multiselect button.dropdown-toggle', match: :first).click
    expect(page).to have_css('.dropdown-menu.show')

    expect(page).to have_content(first_service.name)
  end

  alias_method :and_the_visit_has_one_procedure, :when_i_add_a_procedure
  alias_method :when_i_add_a_similar_procedure, :when_i_add_a_procedure
end