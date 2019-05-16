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

feature "Change Participant Arm", js: :true do

  context "original arm has completed appointments" do
    scenario "Users changes arm on the participant tracker" do
      when_i_start_work_on_an_appointment
      then_i_change_the_arm_of_the_participant
      and_the_visit_group_of_completed_procedure_should_still_appear
      then_i_switch_back_to_the_original_arm
      and_all_the_visits_should_appear
    end
  end

  def when_i_start_work_on_an_appointment
    @protocol     = create_and_assign_protocol_to_me
    @original_arm = @protocol.arms.first
    @protocols_participant  = @protocol.protocols_participants.first
    @protocols_participant.update_attribute(:arm_id, @original_arm.id)
    @procedure = create(:procedure, visit_group: @original_arm.visit_groups.first, completed_date: "08/08/2013")
    @service   = @protocol.organization.inclusive_child_services(:per_participant).first
    
    visit calendar_participants_path(participant_id: @protocols_participant.participant_id, protocols_participant_id: @protocols_participant.id, protocol_id: @protocol)
    wait_for_ajax

  end

  def then_i_change_the_arm_of_the_participant
    @new_arm = create(:arm, protocol_id: @protocol.id)
    @protocols_participant.update_attribute(:arm_id, @new_arm.id)
    
    visit calendar_participants_path(participant_id: @protocols_participant.participant_id, protocols_participant_id: @protocols_participant.id, protocol_id: @protocol)
    wait_for_ajax
  end

  def and_the_visit_group_of_completed_procedure_should_still_appear
    bootstrap_select("#appointment_select", @procedure.visit_group.name)
    wait_for_ajax
  end

  def then_i_switch_back_to_the_original_arm
    @protocols_participant.update_attribute(:arm_id, @original_arm.id)
  end

  def and_all_the_visits_should_appear
    #only tests for one to save time since if last one appears the others should also be there
    bootstrap_select("#appointment_select", @original_arm.visit_groups.last.name)
    wait_for_ajax
  end
end
