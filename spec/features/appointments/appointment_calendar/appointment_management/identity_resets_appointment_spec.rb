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

feature 'User tries to reset appointment', js: true do

  scenario 'and sees the appointment reset' do
    given_i_am_viewing_a_participants_calendar_with_procedures
    when_i_start_the_appointment
    when_i_resolve_all_procedures
    when_i_complete_the_visit
    when_i_click_the_reset_button
    then_i_should_see_a_reset_appointment
  end

  def given_i_am_viewing_a_participants_calendar_with_procedures
    @protocol     = create_and_assign_protocol_to_me
    protocols_participant  = @protocol.protocols_participants.first
    arm           = @protocol.arms.first
    @participant  = Participant.first
    @visit_group  = arm.visit_groups.first
    @appointment  = @visit_group.appointments.where(id: protocols_participant.id).first
    line_item_1   = arm.line_items[0]

    #Add services for the visit group
    # visit protocol_path(@protocol.id)
    # wait_for_ajax
    # find("#line_item_#{line_item_1.id} .check_row").click()
    # accept_confirm
    # wait_for_ajax

    #Select the visit
    visit calendar_protocol_participant_path(id: protocols_participant.id, protocol_id: @protocol)
    wait_for_ajax
    page.find('a.list-group-item[data-appointment-id="1"]').click
    wait_for_ajax
  end

  def when_i_start_the_appointment
    find('a.btn.start-appointment').click
    wait_for_ajax
  end

  def when_i_resolve_all_procedures
    page.all('label.btn.complete.status').each do |btn|
      btn.click
      wait_for_ajax
    end
  end

  def when_i_complete_the_visit
    find("button.complete-appointment").click
    wait_for_ajax
  end

  def when_i_click_the_reset_button
    find("a.btn.reset-appointment").click
    wait_for_ajax

    find('button.swal2-confirm').click
    wait_for_ajax
  end

  def then_i_should_see_a_reset_appointment
    expect(page).to have_css('a.start-appointment', visible: true)
  end
end
