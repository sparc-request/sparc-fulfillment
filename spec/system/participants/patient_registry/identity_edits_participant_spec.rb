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

feature 'User edits Participant', js: true do

  scenario 'and sees the updated Participant' do
    given_i_am_viewing_the_patient_registry
    when_i_update_a_participants_details
    then_i_should_see_the_updated_details
  end

  def given_i_am_viewing_the_patient_registry
    create(:patient_registrar, identity: Identity.first, organization: create(:organization))
    create_and_assign_protocol_to_me
    visit participants_path
    
    expect(page).to have_css('table.participants tbody tr', wait: 5)
  end

  def when_i_update_a_participants_details
    edit_btn = page.find('table.participants tbody tr:first-child td.actions a.edit', wait: 5)
    participant_id = edit_btn["participant_id"]
    edit_btn.hover
    edit_btn.click

    expect(page).to have_field('First Name', wait: 5)
    fill_in 'First Name', with: 'STARLORD'

    @date_of_birth_year = Participant.find(participant_id).date_of_birth.strftime("%Y")
    
    bootstrap_datepicker '#participant_date_of_birth', year: @date_of_birth_year, month: 'Mar', day: '15'

    save_btn = find("input[value='Save Participant']", wait: 5)
    save_btn.hover
    save_btn.click
  end

  def then_i_should_see_the_updated_details
    expect(page).to have_css('#flashes_container', text: 'Participant Updated', wait: 5)

    expect(page).to have_css('table.participants tbody tr td.first_name', text: 'STARLORD', wait: 5)
    date = Date.new(@date_of_birth_year.to_i, 3, 15).strftime("%m/%d/%Y")
    expect(page).to have_css('table.participants tbody tr td.date_of_birth', text: date, wait: 5)
  end
end
