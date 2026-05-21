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

    visit calendar_protocol_participant_path(id: protocols_participant.id, protocol_id: @protocol)
    
    expect(page).to have_css('a.list-group-item.appointment-link')
    first('a.list-group-item.appointment-link').click
    
    expect(page).to have_css('button#addService', visible: true)
  end

  def when_i_start_the_appointment
    find('a.btn.start-appointment').click
    
    expect(page).to have_no_css('a.btn.start-appointment')
    
    if page.has_link?(@visit_group&.name)
      first('a', text: @visit_group.name).click 
    end

    expect(page).to have_css('button.complete-appointment')
  end

  def when_i_resolve_all_procedures
    sleep 0.2 
    
    buttons = page.all('label.btn.complete.status', visible: :all)
    
    buttons.each_with_index do |btn, index|
      btn.click
      
      expect(page).to have_css("label.btn.complete.status.active", count: index + 1, wait: 3)
    end

    expect(page).to_not have_css("button.complete-appointment.disabled")
  end

  def when_i_complete_the_visit
    find("button.complete-appointment").click
    
    expect(page).to have_css("a.btn.reset-appointment", visible: true)
  end

  def when_i_click_the_reset_button
    find("a.btn.reset-appointment").click

    expect(page).to have_css('button.swal2-confirm')
    find('button.swal2-confirm').click
    
    expect(page).to have_no_css('.swal2-container')
  end

  def then_i_should_see_a_reset_appointment
    expect(page).to have_css('a.start-appointment', visible: true)
  end
end
