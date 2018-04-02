# Copyright © 2011-2018 MUSC Foundation for Research Development~
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

feature 'Identity changes a Service', js: true do

  before :each do
    @protocol     = create_and_assign_protocol_to_me
    @participant  = @protocol.participants.first
    @appointment  = @participant.appointments.first
    @services     = @protocol.organization.inclusive_child_services(:per_participant)
  end

  scenario 'and sees it join an existing group' do
    given_i_am_viewing_a_visit_with_one_procedure_group
    and_the_visit_has_one_ungrouped_procedure
    #when_i_change_the_ungrouped_procedure_to_match_the_grouped_procedures
    procedure = Procedure.last

    within "tr.procedure[data-id='#{procedure.id}']" do
      bootstrap_select "#quantity_type_#{procedure.id}", 'T'
    end
    then_i_should_see_the_procedure_in_the_group
  end

  scenario 'and sees it is not longer in its original group' do
    given_i_am_viewing_a_visit_with_one_procedure_group
    when_i_change_the_ungrouped_procedure_to_not_match_the_grouped_procedures
    then_i_should_not_see_the_procedure_in_the_group
  end

  scenario 'and no longer sees the original group' do
    given_i_am_viewing_a_visit_with_one_procedure_group
    when_i_move_all_procedures_out_of_the_group
    then_i_should_not_see_the_procedure_group
  end

  scenario 'and sees the Service is a member of a new group' do
    given_i_am_viewing_a_visit_with_two_procedures_with_different_billing_types
    when_i_change_one_procedure_billing_type_to_be_the_same_as_the_other
    then_i_should_see_one_procedure_group
  end

  scenario 'and sees the quantity incremented in the multiselect menu' do
    given_i_am_viewing_a_visit_with_two_procedures_with_different_billing_types
    when_i_change_one_procedure_billing_type_to_be_the_same_as_the_other
    then_i_should_see_the_quantity_incremented_in_the_multiselect_menu
  end

  scenario 'and sees the Service counter of the joined group has been incremented' do
    given_i_am_viewing_a_visit_with_one_procedure_group
    and_the_visit_has_one_ungrouped_procedure
    when_i_change_the_ungrouped_procedure_to_match_the_grouped_procedures
    then_i_should_see_the_procedure_group_counter_is_four
  end

  scenario 'and sees the Service counter of the original group has been decremented' do
    given_i_am_viewing_a_visit_with_one_procedure_group
    when_i_change_the_ungrouped_procedure_to_not_match_the_grouped_procedures
    then_i_should_see_the_procedure_group_counter_is_two
  end

  def given_i_am_viewing_a_visit_with_two_procedures_with_different_billing_types
    create(:procedure_insurance_billing_qty_with_notes,
            appointment: @appointment,
            service: @services.first,
            sparc_core_name: 'Core',
            sparc_core_id: 1)
    create(:procedure_research_billing_qty_with_notes,
            appointment: @appointment,
            service: @services.first,
            sparc_core_name: 'Core',
            sparc_core_id: 1)

    given_i_am_viewing_a_visit
  end

  def given_i_am_viewing_a_visit_with_one_procedure_group
    create_list(:procedure_insurance_billing_qty_with_notes, 3,
                appointment: @appointment,
                service: @services.first,
                sparc_core_name: 'Core',
                sparc_core_id: 1)

    given_i_am_viewing_a_visit
  end

  def when_i_add_a_procedure
    add_a_procedure @services.first
  end

  def when_i_add_a_different_procedure
    add_a_procedure @services.last
  end

  def and_the_visit_has_one_ungrouped_procedure
    add_a_procedure @services.first
  end

  def when_i_change_one_procedure_billing_type_to_be_the_same_as_the_other
    procedure = Procedure.first

    within "tr.procedure[data-id='#{procedure.id}']" do
      bootstrap_select '.billing_type', 'R'
    end
  end

  def when_i_move_all_procedures_out_of_the_group
    Procedure.all.each do |procedure|
      within "tr.procedure-group" do
        find('button').click
        wait_for_ajax
      end
      within "tr.procedure[data-id='#{procedure.id}']" do
        bootstrap_select '.billing_type', 'R'
        wait_for_ajax
      end
    end
  end

  def when_i_change_the_ungrouped_procedure_to_not_match_the_grouped_procedures
    procedure = Procedure.first

    within "tr.procedure-group[data-group-id='#{procedure.group_id}']" do
      find('button').click
      wait_for_ajax
    end
    within "tr.procedure[data-id='#{procedure.id}']" do
      bootstrap_select '.billing_type', 'R'
    end
  end

  def when_i_change_the_ungrouped_procedure_to_match_the_grouped_procedures
    procedure = Procedure.last

    within "tr.procedure[data-id='#{procedure.id}']" do
      bootstrap_select '.billing_type', 'T'
    end
  end

  def then_i_should_see_the_procedure_group_counter_is_two
    expect(page).to have_css('tr.procedure-group .count', text: '2')
  end

  def then_i_should_see_the_procedure_group_counter_is_four
    expect(page).to have_css('tr.procedure-group .count', text: '4')
  end

  def then_i_should_see_one_procedure_group
    expect(page).to have_css('tr.procedure-group', count: 1)
    within "tr.procedure-group" do
      find('button').click
      wait_for_ajax
    end
    expect(page).to have_css('tr.procedure', count: 2)
  end

  def then_i_should_not_see_the_procedure_group
    expect(page).to_not have_css("tr.procedure-group[data-group-id='#{@original_group_id}']")
  end

  def then_i_should_not_see_the_procedure_in_the_group
    group_id = Procedure.first.group_id

    expect(page).to have_css("tr.procedure[data-group-id='#{group_id}']", count: 1)
  end

  def then_i_should_see_the_procedure_in_the_group
    group_id = Procedure.first.group_id

    expect(page).to have_css("tr.procedure[data-group-id='#{group_id}']", count: 4, visible: false)
  end
  def then_i_should_see_the_quantity_incremented_in_the_multiselect_menu
    find("select#core_multiselect + .btn-group").click
    expect(page).to have_content("2 #{Procedure.first.service_name} R")
  end

end
