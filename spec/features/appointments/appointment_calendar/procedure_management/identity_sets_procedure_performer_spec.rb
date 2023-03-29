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

feature 'User sets Procedure performer', js: true do

  scenario 'completing without selecting a Performer from the Performer dropdown' do
    given_i_have_added_a_procedure_to_an_appointment
    when_i_complete_the_procedure
    then_i_should_see_that_i_am_the_procedure_performer
  end

  scenario 'and then un-completes the Procedure' do
    given_i_have_completed_a_procedure
    when_i_uncomplete_the_procedure
    then_i_should_see_that_the_performer_has_not_been_set
  end

  scenario 'incompleting without selecting a Performer from the Performer dropdown' do
    given_i_have_added_a_procedure_to_an_appointment
    when_i_incomplete_the_procedure
    then_i_should_see_that_i_am_the_procedure_performer
  end

  scenario 'and then un-incompletes the Procedure' do
    given_i_have_incompleted_a_procedure
    when_i_un_incomplete_the_procedure
    then_i_should_see_that_the_performer_has_not_been_set
  end

  def given_i_have_added_a_procedure_to_an_appointment
    protocol    = create_and_assign_protocol_to_me
    protocols_participant = protocol.protocols_participants.first
    visit_group = protocols_participant.appointments.first.visit_group
    service     = protocol.organization.inclusive_child_services(:per_participant).first

    visit calendar_protocol_participant_path(id: protocols_participant.id, protocol_id: protocol)
    wait_for_ajax

    first('a.list-group-item.appointment-link').click
    wait_for_ajax

    add_a_procedure(service)

    @procedure = visit_group.appointments.first.procedures.where(service_id: service.id).first
  end

  def given_i_have_completed_a_procedure
    given_i_have_added_a_procedure_to_an_appointment
    when_i_complete_the_procedure
  end

  def given_i_have_incompleted_a_procedure
    given_i_have_added_a_procedure_to_an_appointment
    when_i_incomplete_the_procedure
  end

  def when_i_complete_the_procedure
    find('a.start-appointment').click
    wait_for_ajax
    find('button.complete-btn').click
    wait_for_ajax
  end

  def when_i_uncomplete_the_procedure
    find('button.unstarted-btn').click
    wait_for_ajax
  end

  def when_i_un_incomplete_the_procedure
    find('button.unstarted-btn').click
    wait_for_ajax
  end

  def when_i_incomplete_the_procedure
    find('a.start-appointment').click
    wait_for_ajax

    find('button.incomplete-btn').click
    wait_for_ajax

    reason = Procedure::NOTABLE_REASONS.first
    bootstrap_select '#procedure_notes_attributes_0_reason', reason
    fill_in 'Comment', with: 'Test comment'
    wait_for_ajax

    find('input[type="submit"]').click

  end

  def then_i_should_see_that_i_am_the_procedure_performer
    expect(page).to have_css("#core#{@procedure.sparc_core_id}ProceduresGroupedView td.performer div.filter-option", text: @logged_in_identity.full_name)
  end

  def then_i_should_see_that_the_performer_has_not_been_set
    expect(page).to_not have_css("#core#{@procedure.sparc_core_id}ProceduresGroupedView td.performer div.filter-option", text: @logged_in_identity.full_name)
  end
end
