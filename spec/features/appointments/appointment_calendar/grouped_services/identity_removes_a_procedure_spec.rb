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

feature 'Identity removes a Procedure', js: true do

  before :each do
    @protocol    = create_and_assign_protocol_to_me
    @protocols_participant = @protocol.protocols_participants.first
    @appointment = @protocols_participant.appointments.first
    @services    = @protocol.organization.inclusive_child_services(:per_participant)
  end

  context 'when group has more than 3 members' do
    before :each do
      given_i_am_viewing_a_visit
      when_i_start_the_appointment
      when_i_add_3_procedures_to_same_group
    end

    scenario 'and no longer sees the Procedure' do
      when_i_remove_the_first_procedure(expected_remaining: 2)
      then_i_should_no_longer_see_that_procedure
    end

    scenario 'and sees the group counter decremented' do
      when_i_remove_the_first_procedure(expected_remaining: 2)
      then_i_should_see_the_group_counter_decrement_by_1
    end
  end

  context 'when group has 2 members' do
    before :each do
      given_i_am_viewing_a_visit
      when_i_start_the_appointment
      when_i_add_2_procedures_to_same_group
    end

    scenario 'and no longer sees the group' do
      when_i_remove_the_first_procedure(expected_remaining: 1)
      then_i_should_no_longer_see_the_group
    end
  end

  def when_i_start_the_appointment
    find('a.btn.start-appointment').click
    # NATIVE SYNC: Wait for the reset button to appear to confirm the appointment has started
    expect(page).to have_css('a.btn.reset-appointment', visible: true, wait: 10)
  end

  def when_i_add_3_procedures_to_same_group
    add_a_procedure @services.first, 3
  end

  def when_i_add_2_procedures_to_same_group
    add_a_procedure @services.first, 2
  end

  def when_i_remove_the_first_procedure(expected_remaining:)
    # SAFELY REVEAL: Expanded means hidden, collapsed means visible
    group_header = first('tr.info.groupBy')
    group_header.click if group_header && group_header[:class].include?('expanded')
    expect(page).to have_css('tr.info.groupBy.collapsed', wait: 10)

    first('a.delete-button').click
    
    # NATIVE SYNC: Wait for SweetAlert modal to fully render, click, and wait for it to vanish
    expect(page).to have_css('.swal2-container', wait: 10)
    find('button.swal2-confirm').click
    expect(page).to have_no_css('.swal2-container', wait: 10)

    # DATA SYNC: Wait for the AJAX to eradicate the row from the DOM entirely
    expect(page).to have_css('a.delete-button', count: expected_remaining, visible: :all, wait: 15)
  end

  def then_i_should_no_longer_see_that_procedure
    # Safely reveal if the AJAX reload happened to snap the group closed again
    group_header = first('tr.info.groupBy')
    group_header.click if group_header && group_header[:class].include?('expanded')
    
    # NATIVE SYNC: Confirm exactly 2 procedure rows remain inside the group
    expect(page).to have_css('tr[data-parent-index="0"]', count: 2, visible: :all, wait: 10)
  end

  def then_i_should_see_the_group_counter_decrement_by_1
    # Check the bold counter text, completely ignoring the brittle visual state of the accordion
    expect(page).to have_css("tr.info.groupBy p strong", text: '2', wait: 10)
  end

  def then_i_should_no_longer_see_the_group
    # When a group drops to 1, the grouping logic dissolves into a singleton. 
    # NATIVE SYNC: Wait for the entire header concept to vanish!
    expect(page).to have_no_css('tr.info.groupBy', wait: 15)
  end
end
