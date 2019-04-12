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

feature 'User creates Participant', js: true do

  scenario 'and sees the new Participants in the list' do
    given_i_am_viewing_the_patient_registry
    when_i_create_a_new_participant
    then_i_should_see_the_new_participant_in_the_list
  end

  def given_i_am_viewing_the_patient_registry
    create(:patient_registrar, identity: Identity.first, organization: create(:organization))
    visit participants_path
    wait_for_ajax
    wait_for_ajax
  end

  def when_i_create_a_new_participant
    find('.new-participant').click

    fill_in 'First Name', with: "Harry"
    fill_in 'Last Name', with: "Potter"
    fill_in 'MRN', with: "1234"
    fill_in 'City', with: "London"
    bootstrap_select '#participant_state', "South Carolina"
    fill_in 'Zip Code', with: "11111"
    bootstrap_datepicker '#dob_time_picker', year: Date.current.year, month: 'Mar', day: '15'
    bootstrap_select '#participant_gender', "Male"
    bootstrap_select '#participant_ethnicity', "Hispanic or Latino"
    bootstrap_select '#participant_race', "Asian"
    fill_in 'Address', with: "123 Hogwarts"
    find("input[value='Save Participant']").click
    wait_for_ajax
  end

  def then_i_should_see_the_new_participant_in_the_list
    expect(page).to have_css('#flashes_container', text: 'Participant Created')
    expect(page).to have_css('table.participants tbody tr', count: 1)
  end

  def then_they_should_have_an_assigned_arm
    expect(Participant.last.arm_id).to eq(@protocol.arms.first.id)
  end

  def then_they_should_not_have_an_assigned_arm
    expect(Participant.last.arm_id).to eq(nil)
  end
end
