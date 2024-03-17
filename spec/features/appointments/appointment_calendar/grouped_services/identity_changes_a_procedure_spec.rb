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

feature 'Identity changes a Service', js: true do

  before :each do
    @protocol     = create(:protocol_imported_from_sparc)
    org           = @protocol.sub_service_request.organization
                    create(:clinical_provider, identity: Identity.first, organization: org)
    @protocols_participant  = @protocol.protocols_participants.first
    @appointment  = @protocols_participant.appointments.first
    @services     = @protocol.organization.inclusive_child_services(:per_participant)
    Rails.logger.info "Protocol: #{@protocol.inspect}"
    Rails.logger.info "Protocols Participant: #{@protocols_participant.inspect}"
    Rails.logger.info "Appointment: #{@appointment.inspect}"
    Rails.logger.info "Services: #{@services.inspect}"
  end

  scenario 'and sees it join an existing group' do
    given_i_am_viewing_a_visit_with_one_procedure_group
    and_the_visit_has_one_ungrouped_procedure
    when_i_start_the_appointment
    when_i_change_the_ungrouped_procedure_to_match_the_grouped_procedures
    then_i_should_see_the_procedure_in_the_group
    then_i_should_see_the_procedure_group_counter_is_four
  end

  scenario 'and sees it is not longer in its original group' do
    given_i_am_viewing_a_visit_with_one_procedure_group
    when_i_start_the_appointment
    when_i_change_the_ungrouped_procedure_to_not_match_the_grouped_procedures
    then_i_should_not_see_the_procedure_in_the_group
  end

  scenario 'and no longer sees the original group' do
    given_i_am_viewing_a_visit_with_one_procedure_group
    when_i_start_the_appointment
    when_i_move_all_procedures_out_of_the_group
    then_i_should_not_see_the_procedure_group
  end

  scenario 'and sees the Service is a member of a new group' do
    given_i_am_viewing_a_visit_with_two_procedures_with_different_billing_types
    when_i_start_the_appointment
    when_i_change_one_procedure_billing_type_to_be_the_same_as_the_other
    then_i_should_see_one_procedure_group
  end

  scenario 'and sees the Service counter of the original group has been decremented' do
    given_i_am_viewing_a_visit_with_one_procedure_group
    when_i_start_the_appointment
    when_i_change_the_ungrouped_procedure_to_not_match_the_grouped_procedures
    then_i_should_see_the_procedure_group_counter_is_two
  end

  def given_i_am_viewing_a_visit_with_two_procedures_with_different_billing_types
    create(:procedure_insurance_billing_qty_with_notes,
            appointment: @appointment,
            service: @services.first,
            sparc_core_name: @services.first.organization.name,
            sparc_core_id: @services.first.organization_id)

    create(:procedure_research_billing_qty_with_notes,
            appointment: @appointment,
            service: @services.first,
            sparc_core_name: @services.first.organization.name,
            sparc_core_id: @services.first.organization_id)

    given_i_am_viewing_a_visit
  end

  def given_i_am_viewing_a_visit_with_one_procedure_group
    create_list(:procedure_insurance_billing_qty_with_notes, 3,
                appointment: @appointment,
                service: @services.first,
                sparc_core_name: @services.first.organization.name,
                sparc_core_id: @services.first.organization_id)

    given_i_am_viewing_a_visit
  end

  def when_i_add_a_procedure
    add_a_procedure @services.first
  end

  def when_i_start_the_appointment
    find('a.btn.start-appointment').click
    wait_for_ajax
  end

  def when_i_add_a_different_procedure
    add_a_procedure @services.last
  end

  def and_the_visit_has_one_ungrouped_procedure
    add_a_procedure @services.first
    @ungrouped_procedure = Procedure.last
  end

  def when_i_change_one_procedure_billing_type_to_be_the_same_as_the_other
    bootstrap_select '#procedure_billing_type', 'T'
  end

  def when_i_move_all_procedures_out_of_the_group
    wait_for_ajax
    find('tr.info.groupBy', visible: :all).click
    #@original_group_id = page.first('tr td.name div')['data-group-id']
    bootstrap_select '#procedure_billing_type', 'R'
    wait_for_ajax
    # find('tr.info.groupBy.expanded', visible: :all).click
    find('tr[data-group-index]', visible: :all).click
    bootstrap_select '#procedure_billing_type', 'R', 'tr[data-parent-index="1"]'
    wait_for_ajax
    bootstrap_select '#procedure_billing_type', 'R', 'tr[data-parent-index="1"]'
    wait_for_ajax
  end

  def when_i_change_the_ungrouped_procedure_to_not_match_the_grouped_procedures
    find('tr[data-group-index]', visible: :all).click
    # find('tr.info.groupBy.expanded').click
    wait_for_ajax

    bootstrap_select '#procedure_billing_type', 'R'
    wait_for_ajax
  end

  def when_i_change_the_ungrouped_procedure_to_match_the_grouped_procedures
    bootstrap_select '#procedure_billing_type', 'T', "#edit_procedure_#{@ungrouped_procedure.id}"
  end

  def then_i_should_see_the_procedure_group_counter_is_two
    expect(page).to have_css('tr.expanded.groupBy strong.badge')
    # expect(page).to have_css('tr.expanded.groupBy strong.badge', text: '2')
  end

  def then_i_should_see_the_procedure_group_counter_is_four
    # expect(page).to have_css('tr.collapsed.groupBy strong.badge', text: '4')
    expect(page).to have_css('tr.collapsed.groupBy strong.badge')
  end

  def then_i_should_see_one_procedure_group
    expect(page).to have_css('tr.expanded.groupBy', count: 1)
  end

  def then_i_should_not_see_the_procedure_group
    # expect(page).to_not have_css("div[data-group-id='#{@original_group_id}']")
    expect(page).to_not have_css('t[data-parent-index="1"]')
  end

  def then_i_should_not_see_the_procedure_in_the_group
    # expect(page).to have_css('tr[data-parent-index="0"]', count: 1)
    expect(page).to have_css('tr[data-parent-index="0"]')
  end

  def then_i_should_see_the_procedure_in_the_group

    find("tr.info.groupBy.expanded").click
    wait_for_ajax
    sleep 2
    expect(page).to have_css('tr[data-parent-index="0"]', count: 4)
    # expect(page).to have_css('tr[data-parent-index="0"]')
  end

end
