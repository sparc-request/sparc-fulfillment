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

feature 'Identity adds a Procedure', js: true do

  before :each do
    @protocol     = create_and_assign_protocol_to_me
    @protocols_participant  = @protocol.protocols_participants.first
    @appointment  = @protocols_participant.appointments.first
    @services     = @protocol.organization.inclusive_child_services(:per_participant)
  end

  scenario 'and sees the procedure in the correct Core' do
    given_i_am_viewing_a_visit
    when_i_add_a_procedure
    then_i_should_see_a_core
  end

  scenario 'and sees the multiselect dropdown instantiated with Select All option and Procedure option' do
    given_i_am_viewing_a_started_visit
    when_i_add_a_procedure
    then_i_should_see_the_multiselect_instantiated_with_2_options
  end

  scenario 'and sees that the Complete and Incomplete buttons on the multiselect are enabled when a Service has been selected' do
    given_i_am_viewing_a_started_visit
    when_i_add_a_procedure
    and_select_a_procedure_from_multiselect
    then_i_should_see_a_enabled_complete_and_incomplete_button
  end

  scenario 'and sees that the Complete and Incomplete buttons on the multiselect are enabled when all Services have been selected' do
    given_i_am_viewing_a_started_visit
    when_i_add_a_procedure
    when_i_add_a_different_procedure
    and_select_all_procedures_from_multiselect
    then_i_should_see_a_enabled_complete_and_incomplete_button
  end

  scenario 'which is part of an existing group and sees the Procedure in a group' do
    given_i_am_viewing_a_visit
    and_the_visit_has_one_grouped_procedure
    when_i_add_a_similar_procedure
    then_i_should_see_three_procedures_in_the_group
  end

  scenario 'and sees the quantity increment for the group in the multiselect dropdown' do
    given_i_am_viewing_a_started_visit
    and_the_visit_has_one_grouped_procedure
    when_i_add_a_similar_procedure
    then_i_should_see_the_quantity_increment_for_the_group_in_the_multiselect_dropdown
  end

  scenario 'which is not part of a group and does not see the Procedure in a group' do
    given_i_am_viewing_a_visit
    and_the_visit_has_one_grouped_procedure
    when_i_add_a_different_procedure
    then_i_should_not_see_the_procedure_in_the_group
  end

  scenario 'which is not part of an existing group and sees a Procedure group created' do
    given_i_am_viewing_a_visit
    and_the_visit_has_one_procedure
    when_i_add_a_similar_procedure
    then_i_should_see_two_procedures_in_the_group
  end

  scenario 'which is part of an existing group and sees the group counter incremented' do
    given_i_am_viewing_a_visit
    and_the_visit_has_one_grouped_procedure
    when_i_add_a_similar_procedure
    then_i_should_see_the_group_counter_is_correct
  end

  def when_i_add_a_procedure
    add_a_procedure @services.first
    @first_procedure = Procedure.last
  end

  def when_i_add_a_different_procedure
    add_a_procedure @services.last
    @second_procedure = Procedure.last
  end

  def then_i_should_see_the_group_counter_is_correct
    group_id = @first_procedure.group_id

    expect(page).to have_css("tr.hidden", count: 3, visible: false)
  end

  def and_select_a_procedure_from_multiselect
    find("button[data-id='core_#{@first_procedure.sparc_core_id}_multiselect']").click
    wait_for_ajax
    
    find("a.dropdown-item").click
    wait_for_ajax
  end

  def and_select_all_procedures_from_multiselect
    find("button[data-id='core_#{@first_procedure.sparc_core_id}_multiselect']").click
    find("button.bs-select-all").click
  end

  def then_i_should_see_a_enabled_complete_and_incomplete_button
    expect(page).to_not have_css("button.complete_all.disabled")
    expect(page).to_not have_css("button.incomplete_all.disabled")
  end

  def then_i_should_not_see_the_procedure_in_the_group
    group_id = @second_procedure.group_id

    expect(page).to have_css("tr[data-index='2']", count: 1)
  end

  def then_i_should_see_two_procedures_in_the_group
    find("button[data-id='core_#{@first_procedure.sparc_core_id}_multiselect']").click
    wait_for_ajax
    
    group_id = @first_procedure.group_id

    expect(page).to have_css("tr.hidden", count: 2, visible: false)
  end

  def then_i_should_see_three_procedures_in_the_group
    find("button[data-id='core_#{@first_procedure.sparc_core_id}_multiselect']").click
    wait_for_ajax

    group_id = @first_procedure.group_id

    expect(page).to have_css("tr.hidden", count: 3, visible: false)
  end

  def then_i_should_see_a_core
    expect(page).to have_css('.core')
  end

  def then_i_should_see_the_multiselect_instantiated_with_2_options
    find("button[data-id='core_#{@first_procedure.sparc_core_id}_multiselect']").click
    expect(page).to have_css("button.bs-select-all")
    expect(page).to have_content("#{@first_procedure.service_name}")
  end

  def then_i_should_see_the_quantity_increment_for_the_group_in_the_multiselect_dropdown
    find("button[data-id='core_#{@first_procedure.sparc_core_id}_multiselect']").click
    expect(page).to have_content("#{@first_procedure.service_name}")
  end

  alias :and_the_visit_has_one_procedure :when_i_add_a_procedure
  alias :when_i_add_a_similar_procedure :when_i_add_a_procedure
end
