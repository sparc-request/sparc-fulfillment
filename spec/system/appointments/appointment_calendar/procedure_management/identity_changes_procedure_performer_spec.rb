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

RSpec.describe 'Identity changes procedure performer', type: :system, js: true do
  let!(:protocol)              { create_and_assign_protocol_to_me }
  let!(:protocols_participant) { protocol.protocols_participants.first }
  let!(:performer)             { create(:identity) }
  let!(:clinical_provider)     { create(:clinical_provider, identity: performer, organization: protocol.organization) }
  let!(:service)               { protocol.organization.inclusive_child_services(:per_participant).first }
  
  # Lazily evaluated: safely queries the DB for the newly created procedure only when called
  let(:procedure)              { protocols_participant.appointments.first.procedures.find_by(service: service) }

  scenario 'and sees a note indicating the performer was changed' do
    given_i_have_added_a_procedure_to_an_appointment
    when_i_select_another_name_in_the_performed_by_dropdown
    when_i_view_the_notes
    then_i_should_see_a_note_indicating_that_the_performer_was_changed
  end

  def given_i_have_added_a_procedure_to_an_appointment
    # Leveraging global helpers to bypass brittle manual setup
    given_i_am_viewing_a_started_visit(participant: protocols_participant, protocol: protocol)
    add_a_procedure(service: service)
  end

  def when_i_select_another_name_in_the_performed_by_dropdown
    bootstrap_select('#procedure_performer_id', performer.full_name)
  end

  def when_i_view_the_notes
    # Dynamically injects the ID of the freshly rendered procedure
    find("div#procedure#{procedure.id}Notes").click
  end

  def then_i_should_see_a_note_indicating_that_the_performer_was_changed
    # Assertion-driven wait: natively polls until the note modal/section renders with the text
    expect(page).to have_css('.note-body', text: "Performer changed to #{performer.full_name}")
  end
end
