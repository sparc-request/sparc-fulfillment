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

feature 'Identity incompletes all Services', js: true do

  before :each do
    DatabaseCleaner[:active_record, model: Procedure].clean_with(:truncation)
    @protocol     = create(:protocol_imported_from_sparc)
    org           = @protocol.sub_service_request.organization
                    create(:clinical_provider, identity: @logged_in_identity, organization: org)
    @protocols_participant  = @protocol.protocols_participants.first
    @appointment  = @protocols_participant.appointments.first
    @services     = @protocol.organization.inclusive_child_services(:per_participant)
  end

  context 'after visit has begun' do
    before :each do
      given_i_am_viewing_a_started_visit
      when_i_add_some_ungrouped_procedures
      and_i_add_some_grouped_procedures
    end

    scenario 'selects all procedures' do
      when_i_select_all_procedures_in_the_core_dropdown
      and_i_click_incomplete_all_and_give_a_reason
      and_i_unroll_accordion
      then_all_procedures_should_remain_incomplete
    end

    scenario 'selects an ungrouped procedure' do
      when_i_select_an_ungrouped_procedure_in_the_core_dropdown
      and_i_click_incomplete_all_and_give_a_reason
      then_the_selected_procedures_should_be_incompleted
    end

    scenario 'selects multiple but not all ungrouped procedures' do
      when_i_select_multiple_but_not_all_ungrouped_procedures_in_the_core_dropdown
      and_i_click_incomplete_all_and_give_a_reason
      then_the_selected_procedures_should_be_incompleted
    end

    scenario 'selects all ungrouped procedures' do
      when_i_select_all_ungrouped_procedures_in_the_core_dropdown
      and_i_click_incomplete_all_and_give_a_reason
      then_the_selected_procedures_should_be_incompleted
    end

    scenario 'selects all grouped procedures' do
      when_i_select_all_grouped_procedures_in_the_core_dropdown
      and_i_click_incomplete_all_and_give_a_reason
      and_i_unroll_accordion
      then_the_selected_procedures_should_be_incompleted
    end

    scenario 'selects all procedures' do
      when_i_select_all_procedures_in_the_core_dropdown
      and_i_click_incomplete_all_and_give_a_reason
      and_i_unroll_accordion
      then_the_selected_procedures_should_be_incompleted
    end
  end

  def when_i_add_some_ungrouped_procedures
    @services[0..2].each do |service|
      add_a_procedure service, 1
    end
  end

  def and_i_add_some_grouped_procedures
    add_a_procedure @services.fourth, 2
  end

  def when_i_select_an_ungrouped_procedure_in_the_core_dropdown
    @selected = [@services.first]
    bootstrap_multiselect '.core_multiselect', @selected.map(&:name)
  end

  def when_i_select_multiple_but_not_all_ungrouped_procedures_in_the_core_dropdown
    @selected = @services[0..1]
    bootstrap_multiselect '.core_multiselect', @selected.map(&:name)
  end

  def when_i_select_all_ungrouped_procedures_in_the_core_dropdown
    @selected = @services[0..2]
    bootstrap_multiselect '.core_multiselect', @selected.map(&:name)
  end

  def when_i_select_all_grouped_procedures_in_the_core_dropdown
    @selected = [@services.fourth]
    bootstrap_multiselect '.core_multiselect', @selected.map(&:name)
  end

  def when_i_select_all_procedures_in_the_core_dropdown
    @selected = @services
    bootstrap_multiselect '.core_multiselect'
  end

  def and_i_click_incomplete_all_and_give_a_reason
    find('button.incomplete-all').click
    wait_for_ajax
    bootstrap_select '[name="performer_id"]', "Sally"
    reason = Procedure::NOTABLE_REASONS.first
    bootstrap_select '[name="reason"]', reason
    fill_in 'comment', with: 'Test comment'
    find('input[value="Submit"]').click
    wait_for_ajax
  end

  def and_i_unroll_accordion
    find("tr.info.groupBy.expanded").click
    wait_for_ajax
  end

  def then_the_selected_procedures_should_be_incompleted
    selected_procedures, unselected_procedures = Procedure.all.partition { |p| @selected.include? p.service }

    selected_procedures.each do |procedure|
      expect(procedure.status).to eq 'incomplete'
    end

    unselected_procedures.each do |procedure|
      expect(procedure.status).to eq 'unstarted'
    end
  end

  def then_all_procedures_should_remain_incomplete
    Procedure.all.each do |p|
      expect(p.status).to eq 'incomplete'
    end
  end
end
