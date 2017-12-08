# Copyright © 2011-2017 MUSC Foundation for Research Development~
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

feature 'User changes Participant Arm', js: true do

  scenario 'and sees the updated Participant' do
    given_i_am_viewing_the_participant_tracker
    when_i_change_a_participants_arm
    then_i_should_see_the_arm_is_updated
  end

  def given_i_am_viewing_the_participant_tracker
    protocol    = create_and_assign_protocol_to_me
    @second_arm  = protocol.arms.second

    visit protocol_path(protocol.id)
    wait_for_ajax

    click_link 'Participant Tracker'
    wait_for_ajax
  end

  def when_i_change_a_participants_arm
    page.find('table.participants tbody tr:first-child td.change_arm a').click
    wait_for_ajax
    bootstrap_select "#participant_arm_id", @second_arm.name

    click_button 'Save'
    wait_for_ajax
  end

  def then_i_should_see_the_arm_is_updated
    expect(page).to have_css('#flashes_container', text: 'Participant Successfully Changed Arms')
    expect(page).to have_css('table.participants tbody tr:first-child td.arm_name', text: @second_arm.name)
  end
end
