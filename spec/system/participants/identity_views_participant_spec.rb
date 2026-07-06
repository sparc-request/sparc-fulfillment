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

RSpec.describe 'User views Participant', type: :system, js: true do
  let(:logged_in_identity) { @logged_in_identity || create(:identity) }

  context 'when the user does not have access to the protocol' do
    let!(:protocol)              { create(:protocol_imported_from_sparc) }
    let!(:participant)           { create(:participant) }
    let!(:protocols_participant) { create(:protocols_participant, protocol: protocol, participant: participant) }

    scenario 'is redirected to the home page' do
      # Intentionally not using the global `given_i_am_viewing_a_visit` helper here since it natively waits for the calendar DOM to render... since a redirect is expected, navigate manually
      visit calendar_protocol_participant_path(id: participant.id, protocol_id: protocol.id)
      
      expect(page).to have_current_path(root_path, ignore_query: true)
    end
  end

  context 'when the user has access to the protocol' do
    let!(:protocol)    { create_and_assign_protocol_to_me(identity: logged_in_identity) }
    let!(:arm)         { create(:arm, protocol: protocol, name: 'Treatment Arm A') }
    
    let!(:participant) { create(:participant, first_name: 'Tony', last_name: 'Stark', mrn: '123456789') }
    let!(:protocols_participant) do 
      create(:protocols_participant, 
             protocol: protocol, 
             arm: arm, 
             participant: participant) 
    end

    scenario 'sees the Participants attributes in the header' do
      # Bypassing the global helper because it expects an appointment to exist so it can click it.
      visit calendar_protocol_participant_path(id: participant.id, protocol_id: protocol.id)
      
      then_i_should_see_the_participant_attributes(protocols_participant: protocols_participant)
    end
  end

  context 'when the user has access to a protocol with appointments' do
    let!(:protocol)    { create_and_assign_protocol_to_me(identity: logged_in_identity) }
    let!(:participant) { create(:participant, first_name: 'Bruce', last_name: 'Banner') }
    let!(:protocols_participant) do
      create(:protocols_participant_with_completed_appointments,
             protocol: protocol,
             arm: protocol.arms.first || create(:arm, protocol: protocol),
             participant: participant)
    end

    scenario 'sees a list of Visits' do
      # Navigating directly to the page is enough to naturally render the list of visits
      visit calendar_protocol_participant_path(id: participant.id, protocol_id: protocol.id)
      
      then_i_should_see_the_list_of_visits(appointments: protocols_participant.appointments)
    end
  end

  def then_i_should_see_the_participant_attributes(protocols_participant:)
    participant = protocols_participant.participant

    within('.modal') do
      expect(page).to have_text(/#{Regexp.quote(participant.full_name)}/i)
      expect(page).to have_text(/#{Regexp.quote(participant.mrn)}/i)
    end
  end

  def then_i_should_see_the_list_of_visits(appointments:)
    expect(page).to have_css('#appointmentsList')

    appointments.each do |appointment|
      expect(page).to have_css("div#appointmentsList a[data-appointment-id='#{appointment.id}']", text: /#{Regexp.quote(appointment.name)}/i)
    end
  end
end
