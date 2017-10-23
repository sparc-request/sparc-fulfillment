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

feature 'User creates Participant', js: true do

  scenario 'and sees the new Participants in the list' do
    given_i_am_viewing_the_participant_tracker
    when_i_create_a_new_participant
    then_i_should_see_the_new_participant_in_the_list
  end

  def given_i_am_viewing_the_participant_tracker
    @protocol = create_and_assign_protocol_to_me

    visit protocol_path(@protocol.id)
    wait_for_ajax

    click_link 'Participant Tracker'
    wait_for_ajax
  end

  def when_i_create_a_new_participant
    find('.new-participant').click

    participant = build(:participant_with_protocol)

    fill_in 'First Name', with: participant.first_name
    fill_in 'Last Name', with: participant.last_name
    fill_in 'MRN', with: participant.mrn
    fill_in 'City', with: participant.city
    bootstrap_select '#participant_state', participant.state
    fill_in 'Zip Code', with: participant.zipcode
    bootstrap_select '#participant_status', participant.status
    page.execute_script %Q{ $("#dob_time_picker").trigger("focus") }

    page.execute_script %Q{ $("td.year:contains('0')").trigger("click") }
    page.execute_script %Q{ $("td.month:contains('Mar')").trigger("click") }
    page.execute_script %Q{ $("td.day:contains('15')").trigger("click") }
    bootstrap_select '#participant_gender', "Female"
    bootstrap_select '#participant_ethnicity', "Hispanic or Latino"
    bootstrap_select '#participant_race', "Asian"
    fill_in 'Address', with: "123 Fake Street"

    find("input[value='Save Participant']").click
    wait_for_ajax
  end

  def then_i_should_see_the_new_participant_in_the_list
    expect(page).to have_css('#flashes_container', text: 'Participant Created')
    expect(page).to have_css('table.participants tbody tr', count: 4)
  end

  def then_they_should_have_an_assigned_arm
    expect(Participant.last.arm_id).to eq(@protocol.arms.first.id)
  end

  def then_they_should_not_have_an_assigned_arm
    expect(Participant.last.arm_id).to eq(nil)
  end
end
