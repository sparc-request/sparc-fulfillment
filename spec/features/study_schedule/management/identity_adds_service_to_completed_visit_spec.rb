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

feature 'Identity adds service to completed visit', js: :true do

  describe 'user adds a service' do

    it 'should not create procedures for a completed visit' do

      protocol = create_and_assign_protocol_to_me
      arm       = create(:arm_with_visit_groups, protocol: protocol)
      services  = protocol.organization.inclusive_child_services(:per_participant)
      line_item = create(:line_item, arm: arm, service: services.first, protocol: protocol)
      protocols_participant  = create(:protocols_participant_with_appointments, protocol: protocol, arm: protocol.arms.first, participant: create(:participant))
      procedure    = create(:procedure_complete, appointment: protocols_participant.appointments.first, arm: protocol.arms.first, status: "complete", completed_date: Date.today.strftime('%m/%d/%Y'), service: services.first)

      visit protocol_path protocol
      wait_for_ajax

      find('#studyScheduleTabLink').click
      wait_for_ajax

      visit_id = VisitGroup.first.id
      procedure_count = Procedure.all.count

      find("#line_item_#{line_item.id} .check-row").click
      accept_confirm
      wait_for_ajax


      expect(Procedure.all.count).to eq(procedure_count)
    end
  end
end
