# Copyright © 2011-2017 MUSC Foundation for Research Development~
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

feature 'User changes performer of a procedure', js: true do

  scenario 'and sees a note indicating the performer was changed' do
    given_i_have_added_a_procedure_to_an_appointment
    when_i_select_another_name_in_the_performed_by_dropdown
    when_i_view_the_notes
    then_i_should_see_a_note_indicating_that_the_performer_was_changed
  end

  def given_i_have_added_a_procedure_to_an_appointment
    protocol    = create_and_assign_protocol_to_me
    @performer  = create(:identity)
    ClinicalProvider.create(identity: @performer, organization: protocol.organization)
    participant = protocol.participants.first
    visit_group = participant.appointments.first.visit_group
    service     = protocol.organization.inclusive_child_services(:per_participant).first

    visit participant_path participant
    wait_for_ajax

    bootstrap_select '#appointment_select', visit_group.name
    wait_for_ajax
    
    bootstrap_select '#service_list', service.name
    fill_in 'service_quantity', with: 1
    find('button.add_service').click
    wait_for_ajax

    find('button.start_visit').click
    wait_for_ajax

    visit_group.appointments.first.procedures.reload
    @procedure = visit_group.appointments.first.procedures.where(service_id: service.id).first
  end

  def when_i_select_another_name_in_the_performed_by_dropdown
    bootstrap_select "#performed-by-#{@procedure.id}", @performer.full_name
  end

  def when_i_view_the_notes
    find('.procedure td.notes button.notes.list').click
  end

  def then_i_should_see_a_note_indicating_that_the_performer_was_changed
    expect(page).to have_css('.modal-body .comment', text: "Performer changed to #{@performer.full_name}")
  end
end
