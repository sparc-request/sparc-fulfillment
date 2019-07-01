# Copyright © 2011-2019 MUSC Foundation for Research Development~
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

feature 'Identity adds Procedure', js: true do

  scenario 'and sees it in the appointment calendar' do
    given_i_am_viewing_a_participants_calendar
    when_i_add_a_procedure
    then_i_should_see_the_procedure_in_the_appointment_calendar
  end

  scenario 'and sees that the Performed By selector does not have a selection' do
    given_i_am_viewing_a_participants_calendar
    when_i_add_a_procedure
    then_i_should_see_that_the_performed_by_selector_does_not_have_a_selection
  end

  def given_i_am_viewing_a_participants_calendar
    @protocol     = create_and_assign_protocol_to_me
    @protocols_participant  = @protocol.protocols_participants.first
    visit calendar_participants_path(participant_id: @protocols_participant.participant_id, protocols_participant_id: @protocols_participant.id, protocol_id: @protocol)
    wait_for_ajax
  end

  def when_i_add_a_procedure
    visit_group = @protocols_participant.appointments.first.visit_group
    service     = @protocol.organization.inclusive_child_services(:per_participant).first

    bootstrap_select('#appointment_select', visit_group.name)
    bootstrap_select('#service_list', service.name)
    fill_in 'service_quantity', with: '1'
    page.find('button.add_service').click
    wait_for_ajax
  end

  def then_i_should_see_the_procedure_in_the_appointment_calendar
    expect(page).to have_css('.procedures .procedure', count: 1)
  end

  def then_i_should_see_that_the_performed_by_selector_does_not_have_a_selection
    expected_value = page.evaluate_script %Q{ $('table.procedures .performed-by-dropdown').val(); }

    expect(expected_value).to eq('')
  end
end
