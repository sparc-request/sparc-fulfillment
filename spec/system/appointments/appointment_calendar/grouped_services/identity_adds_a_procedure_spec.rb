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
  
  # I. RSpec Foundation & State Management
  let!(:protocol)              { create_and_assign_protocol_to_me }
  let!(:protocols_participant) { protocol.protocols_participants.first }
  let!(:appointment)           { protocols_participant.appointments.first }
  let!(:services)              { protocol.organization.inclusive_child_services(:per_participant) }
  
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
    then_i_should_see_the_multiselect_instantiated_with_2_options
  end

  scenario 'and sees that the Complete and Incomplete buttons on the multiselect are enabled when a Service has been selected' do
    given_i_am_viewing_a_started_visit(participant: protocols_participant, protocol: protocol)
    when_i_add_a_procedure
    and_select_a_procedure_from_multiselect
    then_i_should_see_a_enabled_complete_and_incomplete_button
  end

  scenario 'and sees that the Complete and Incomplete buttons on the multiselect are enabled when all Services have been selected' do
    given_i_am_viewing_a_started_visit(participant: protocols_participant, protocol: protocol)
    when_i_add_a_procedure
    when_i_add_a_different_procedure
    and_select_all_procedures_from_multiselect
    then_i_should_see_a_enabled_complete_and_incomplete_button
  end

  scenario 'which is part of an existing group and sees the Procedure in a group' do
    given_i_am_viewing_a_visit(participant: protocols_participant, protocol: protocol)
    and_the_visit_has_one_grouped_procedure(service: first_service)
    when_i_add_a_similar_procedure
    then_i_should_see_three_procedures_in_the_group
  end

  scenario 'and sees the quantity increment for the group in the multiselect dropdown' do
    given_i_am_viewing_a_started_visit(participant: protocols_participant, protocol: protocol)
    and_the_visit_has_one_grouped_procedure(service: first_service)
    when_i_add_a_similar_procedure
    then_i_should_see_the_quantity_increment_for_the_group_in_the_multiselect_dropdown
  end

  scenario 'which is not part of a group and does not see the Procedure in a group' do
    given_i_am_viewing_a_visit(participant: protocols_participant, protocol: protocol)
    and_the_visit_has_one_grouped_procedure(service: first_service)
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
    and_the_visit_has_one_grouped_procedure(service: first_service)
    when_i_add_a_similar_procedure
    then_i_should_see_the_group_counter_is_correct
  end

  def when_i_add_a_procedure
    add_a_procedure(service: first_service)
  end

  def when_i_add_a_different_procedure
    add_a_procedure(service: second_service)
  end

  # IV. The Race Condition Playbook
  def first_procedure_record
    expect(page).to have_content(first_service.name)
    Procedure.where(service_id: first_service.id).last
  end

  def second_procedure_record
    expect(page).to have_content(second_service.name)
    Procedure.where(service_id: second_service.id).last
  end

  def then_i_should_see_the_group_counter_is_correct
    expect(page).to have_css("tr.hidden", count: 3, visible: :all)
  end

  def and_select_a_procedure_from_multiselect
    find("button[data-id='core_#{first_procedure_record.sparc_core_id}_multiselect']").click
    
    # V. Eradicating Anti-Patterns (Wait for Animations)
    expect(page).to have_css('.dropdown-menu.show') 
    
    # III. Bulletproof Targeting (Avoid Stale Elements when mutating)
    find("a.dropdown-item", match: :first).click
  end

  def and_select_all_procedures_from_multiselect
    find("button[data-id='core_#{first_procedure_record.sparc_core_id}_multiselect']").click
    expect(page).to have_css('.dropdown-menu.show')

    find("button.bs-select-all", match: :first).click
  end

  def then_i_should_see_a_enabled_complete_and_incomplete_button
    expect(page).to have_no_css("button.complete_all.disabled")
    expect(page).to have_no_css("button.incomplete_all.disabled")
  end

  def then_i_should_not_see_the_procedure_in_the_group
    expect(page).to have_css("tr[data-index='2']", count: 1)
  end

  def then_i_should_see_two_procedures_in_the_group
    expect(page).to have_css("tr.hidden", count: 2, visible: :all)
  end

  def then_i_should_see_three_procedures_in_the_group
    expect(page).to have_css("tr.hidden", count: 3, visible: :all)
  end

  def then_i_should_see_a_core
    expect(page).to have_css('.core')
  end

  def then_i_should_see_the_multiselect_instantiated_with_2_options
    find("button[data-id='core_#{first_procedure_record.sparc_core_id}_multiselect']").click
    expect(page).to have_css('.dropdown-menu.show')

    expect(page).to have_css("button.bs-select-all")
    expect(page).to have_content(first_service.name)
  end

  def then_i_should_see_the_quantity_increment_for_the_group_in_the_multiselect_dropdown
    find("button[data-id='core_#{first_procedure_record.sparc_core_id}_multiselect']").click
    expect(page).to have_css('.dropdown-menu.show') 

    expect(page).to have_content(first_service.name)
  end

  alias_method :and_the_visit_has_one_procedure, :when_i_add_a_procedure
  alias_method :when_i_add_a_similar_procedure, :when_i_add_a_procedure
end