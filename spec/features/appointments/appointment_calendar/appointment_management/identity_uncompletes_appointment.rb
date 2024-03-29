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

feature 'Identity uncompletes an appointment', js: true do

  scenario 'and sees the completed date reset' do
    given_i_have_added_a_procedure_to_an_appointment
    when_i_begin_the_appointment
    when_i_complete_the_procedure
    when_i_complete_the_appointment
    when_i_uncomplete_the_appointment
    then_i_should_see_the_appointment_is_uncomplete
  end

  def given_i_have_added_a_procedure_to_an_appointment
    protocol    = create_and_assign_protocol_to_me
    @protocols_participant = protocol.protocols_participants.first
    visit_group = @protocols_participant.appointments.first.visit_group
    service     = protocol.organization.inclusive_child_services(:per_participant).first

    visit calendar_protocol_participant_path(id: @protocols_participant.id, protocol_id: protocol)
    wait_for_ajax

    find('div.list-group-flush a:nth-child(1)').click
    wait_for_ajax
    
    bootstrap_select '[name="service_id"]', service.name
    fill_in 'service_quantity', with: 1
    find('button#addService').click
    wait_for_ajax
  end

  def when_i_begin_the_appointment
    find('a.start-appointment').click
    wait_for_ajax
  end

  def when_i_complete_the_procedure
    find('button.complete-btn[data-status="complete"]').click
    wait_for_ajax
  end

  def when_i_complete_the_appointment
    find('button.complete-appointment').click
    wait_for_ajax
  end

  def when_i_uncomplete_the_appointment
    find('button.unstarted-btn').click
    wait_for_ajax
  end

  def then_i_should_see_the_appointment_is_uncomplete
    expect(page).to have_css('button.complete-appointment', visible: true)
    # expect(page).to have_css('div.input#procedure_completed_date.hidden', visible: false)
  end
end


