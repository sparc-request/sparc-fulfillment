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

RSpec.describe 'User tries to reset appointment', type: :system, js: true do
  let(:protocol) { create_and_assign_protocol_to_me(identity: @logged_in_identity) }
  let(:protocols_participant) { protocol.protocols_participants.first }
  let(:visit_group) { protocol.arms.first.visit_groups.first }

  scenario 'and sees the appointment reset' do
    given_i_am_viewing_a_participants_calendar_with_procedures
    when_i_start_the_appointment
    when_i_resolve_all_procedures
    when_i_complete_the_visit
    when_i_click_the_reset_button
    then_i_should_see_a_reset_appointment
  end

  def given_i_am_viewing_a_participants_calendar_with_procedures
    visit calendar_protocol_participant_path(id: protocols_participant.id, protocol_id: protocol.id)
    
    # Use match: :first to dodge duplicate sidebar elements
    find('a.list-group-item.appointment-link', text: visit_group.name, match: :first).click
    
    within('#appointmentContainer') do
      expect(page).to have_css('h3', text: /#{visit_group.name}/i)
    end
  end

  def when_i_start_the_appointment
    click_link 'Start Visit'
    expect(page).to have_no_link('Start Visit')

    find('a.list-group-item, a.visit-group-link', text: visit_group.name, match: :first).click
    
    within('#appointmentContainer') do
      expect(page).to have_css('h3', text: /#{visit_group.name}/i)
    end
  end

  def when_i_resolve_all_procedures
    within('#appointmentContainer') do
      button_count = all('.complete-btn, label.complete.status').count
      
      button_count.times do |index|
        all('.complete-btn, label.complete.status')[index].click
      end
    end
  end

  def when_i_complete_the_visit
    expect(page).to have_button('Complete Visit', disabled: false) 
    click_button 'Complete Visit'
    
    expect(page).to have_field('Completed Date')
  end

  def when_i_click_the_reset_button
    click_link 'Reset Visit' 

    within('.swal2-container') do
      find('button.swal2-confirm').click
    end
    
    expect(page).to have_no_css('.swal2-container')
  end

  def then_i_should_see_a_reset_appointment
    expect(page).to have_link('Start Visit')
  end
end
