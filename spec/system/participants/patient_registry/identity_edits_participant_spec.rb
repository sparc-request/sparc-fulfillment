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

RSpec.describe 'User edits Participant', type: :system, js: true do
  let(:logged_in_identity) { @logged_in_identity || create(:identity) }
  let!(:organization)      { create(:organization) }
  let!(:patient_registrar) { create(:patient_registrar, identity: logged_in_identity, organization: organization) }
  
  # Explicitly creating the participant so we aren't relying on phantom factory side-effects
  let!(:participant) { create(:participant, first_name: 'Peter', last_name: 'Quill') }

  scenario 'sees the updated Participant details' do
    given_i_am_viewing_the_patient_registry
    when_i_update_the_participants_details(last_name: 'Quill', new_first_name: 'Starlord')
    then_i_should_see_the_updated_details(new_first_name: 'Starlord', expected_month: 'Mar', expected_day: '15')
  end

  def given_i_am_viewing_the_patient_registry
    visit participants_path
    
    expect(page).to have_css('table.participants')
  end

  def when_i_update_the_participants_details(last_name:, new_first_name:)
    within('table.participants tbody tr', text: /#{Regexp.quote(last_name)}/i) do
      find('a.edit').click
    end

    fill_in 'First Name', with: new_first_name
    
    expected_date = Date.parse("15 Mar #{Date.current.year}").strftime("%m/%d/%Y")

    # Passing BOTH the individual components (for readonly mode) AND the text string (for standard input mode)
    bootstrap_datepicker '#participant_date_of_birth', year: Date.current.year, month: 'Mar', day: '15', text: expected_date

    click_button 'Save Participant'
  end

  def then_i_should_see_the_updated_details(new_first_name:, expected_month:, expected_day:)
    expect(page).to have_no_css('.modal-dialog')

    expect(page).to have_css('#flashes_container', text: /Participant Updated/i)

    expected_date = Date.parse("#{expected_day} #{expected_month} #{Date.current.year}").strftime("%m/%d/%Y")
    
    within('table.participants tbody tr', text: /#{Regexp.quote(new_first_name)}/i) do
      expect(page).to have_css('td.first_name', text: /#{Regexp.quote(new_first_name)}/i)
      expect(page).to have_css('td.date_of_birth', text: expected_date)
    end

    # CWF actively normalizes Participant names to uppercase
    expect(participant.reload.first_name).to eq(new_first_name.upcase)
    expect(participant.date_of_birth.strftime("%m/%d/%Y")).to eq(expected_date)
  end
end
