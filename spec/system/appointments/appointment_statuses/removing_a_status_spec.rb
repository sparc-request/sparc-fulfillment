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

RSpec.describe 'Removing a Status', type: :system, js: true do
  let(:protocol)              { create_and_assign_protocol_to_me }
  let(:protocols_participant) { protocol.protocols_participants.first }
  let(:appointment)           { protocols_participant.appointments.first }

  scenario 'user removes an appointment status and sees it destroyed' do
    given_i_am_viewing_a_visit(participant: protocols_participant, protocol: protocol)
    when_i_select_and_then_deselect_an_appointment_status
    then_the_appointment_status_should_be_destroyed_for_that_appointment
  end

  def when_i_select_and_then_deselect_an_appointment_status
    bootstrap_select('#statuses', 'Skipped Visit')
    
    find('body').click(x: 0, y: 0)
    
    # Hand-rolling the deselection leveraging 'bootstrap_wrapper' - cannot just call `bootstrap_select` again here
    bootstrap_wrapper('#statuses').find('.dropdown-toggle').click
    expect(bootstrap_wrapper('#statuses')).to have_css('.dropdown-menu.show')
    
    bootstrap_wrapper('#statuses').find('.dropdown-menu.show span.text', text: 'Skipped Visit', exact_text: true, visible: true).click
    
    # Native Sync Point: ensure the deselection actually registered in the UI
    expect(bootstrap_wrapper('#statuses')).to have_no_css('.filter-option-inner-inner', text: 'Skipped Visit', exact_text: true)
  end

  def then_the_appointment_status_should_be_destroyed_for_that_appointment
    # Reload the association to ensure we pull the fresh state from the database
    expect(appointment.appointment_statuses.reload.size).to eq(0)
  end
end
