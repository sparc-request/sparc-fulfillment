# Copyright © 2011-2023 MUSC Foundation for Research Development
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

RSpec.describe 'User deletes Participant', type: :system, js: true do
  # Establish the global user state
  let(:logged_in_identity) { @logged_in_identity || create(:identity) }
  let!(:organization)      { create(:organization) }
  let!(:patient_registrar) { create(:patient_registrar, identity: logged_in_identity, organization: organization) }

  context 'when the participant has no procedure data' do
    # Explicitly generate the participant so as not to rely on `Participant.last` factory magic
    let!(:participant) { create(:participant, first_name: 'Luke', last_name: 'Skywalker') }

    before do
      participant.protocols_participants.destroy_all
    end

    scenario 'sees the Participant is removed from the list' do
      given_i_am_viewing_the_patient_registry
      when_i_delete_the_participant(last_name: 'Skywalker')
      then_i_should_not_see_the_participant(last_name: 'Skywalker')
    end
  end

  context 'when the participant has procedure data' do
    # Explicitly defining the data hierarchy that triggers the disabled state
    let!(:protocol)              { create(:protocol) }
    let!(:arm)                   { create(:arm, protocol: protocol) }
    let!(:participant)           { create(:participant, first_name: 'Darth', last_name: 'Vader') }
    let!(:protocols_participant) { create(:protocols_participant, arm: arm, protocol: protocol, participant: participant) }
    let!(:visit_group)           { create(:visit_group, arm: arm, name: 'Death Star Visit') }
    let!(:appointment)           { create(:appointment, visit_group: visit_group, protocols_participant: protocols_participant, name: visit_group.name, arm: arm) }
    let!(:procedure)             { create(:procedure, :complete, appointment: appointment) }

    scenario 'sees a disabled delete button' do
      given_i_am_viewing_the_patient_registry
      then_i_should_see_disabled_delete_button_for(last_name: 'Vader')
    end
  end

  def given_i_am_viewing_the_patient_registry
    visit participants_path
    expect(page).to have_css('table.participants')
  end

  def when_i_delete_the_participant(last_name:)
    within('table.participants tbody tr', text: /#{Regexp.quote(last_name)}/i) do
      accept_confirm do
        find('a.remove').click
      end
    end
  end

  def then_i_should_not_see_the_participant(last_name:)
    expect(page).to have_css('#flashes_container', text: /Participant Removed/i)
    
    expect(page).to have_no_css('table.participants tbody tr', text: /#{Regexp.quote(last_name)}/i)
    
    expect(Participant.count).to eq(0)
  end

  def then_i_should_see_disabled_delete_button_for(last_name:)
    expect(page).to have_css('table.participants tbody tr', text: /#{Regexp.quote(last_name)}/i)

    within('table.participants tbody tr', text: /#{Regexp.quote(last_name)}/i) do
      expect(page).to have_css('a[data-original-title="Participants with procedure data cannot be deleted."]')
    end
  end
end
