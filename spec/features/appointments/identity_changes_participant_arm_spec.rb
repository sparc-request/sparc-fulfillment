# Copyright © 2011-2020 MUSC Foundation for Research Development~
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
  context "original arm does NOT have completed procedures" do
    scenario "User changes arm on the participant tracker" do
      when_i_start_work_on_an_appointment
      then_i_change_the_arm_of_the_participant
      and_i_visit_the_calendar_again
      i_should_only_see_new_appointments
    end
  end
  context "original arm has completed procedures" do
    scenario "User changes arm on the participant tracker" do
      when_i_start_work_on_an_appointment
      and_i_complete_a_procedure
      then_i_change_the_arm_of_the_participant
      and_i_visit_the_calendar_again
      i_should_see_new_and_old_appointments
    end
  end


  def when_i_start_work_on_an_appointment
    @protocol     = create_and_assign_protocol_to_me
    @protocols_participant  = @protocol.protocols_participants.first
    @original_arm = @protocols_participant.arm
    @second_arm   = @protocol.arms.where.not(id: @original_arm.id).first
    @service      = @protocol.organization.inclusive_child_services(:per_participant).first
    @original_appointment = @original_arm.visit_groups.first

    @service.update_attributes(name: 'Test Service')
    @original_appointment.update_attributes(name: "First Arm Appointment")

    given_i_am_viewing_a_visit

    find('a.start-appointment').click
    wait_for_ajax

    add_a_procedure(@service)
  end

  def and_i_complete_a_procedure
    find('button.complete-btn').click
    wait_for_ajax
  end

  def then_i_change_the_arm_of_the_participant
    visit protocol_path(@protocol.id)
    wait_for_ajax

    click_link 'Participant Tracker'
    wait_for_ajax

    bootstrap_select("#protocols_participant_arm_id", @second_arm.name, "#edit_protocols_participant_#{@protocols_participant.id}" )
    wait_for_ajax
  end

  def and_i_visit_the_calendar_again
    given_i_am_viewing_a_visit
  end

  def i_should_see_new_and_old_appointments
    expect(page).to have_css("a.appointment-link span", text: @original_appointment.name)
    expect(page).to have_css("a.appointment-link span", text: @second_arm.visit_groups.first.name)
  end

  def i_should_only_see_new_appointments
    expect(page).to_not have_css("a.appointment-link span", text: @original_appointment.name)
    expect(page).to have_css("a.appointment-link span", text: @second_arm.visit_groups.first.name)
  end

end
