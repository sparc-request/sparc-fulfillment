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

RSpec.describe 'User creates Participant', type: :system, js: true do
  let(:logged_in_identity) { @logged_in_identity || create(:identity) }
  let!(:organization)      { create(:organization) }
  let!(:patient_registrar) { create(:patient_registrar, identity: logged_in_identity, organization: organization) }

  # Physically mutate the process-global ENV hash so the Puma server thread can see it
  around do |example|
    original_mrn_setting = ENV['VALIDATE_MRN']
    ENV['VALIDATE_MRN'] = validate_mrn.to_s
    
    example.run
    
    # Safely restore the environment for the rest of the suite
    ENV['VALIDATE_MRN'] = original_mrn_setting
  end

  context 'when VALIDATE_MRN is true' do
    let(:validate_mrn) { true }

    context 'with a numerical MRN' do
      scenario 'sees the new Participant in the list' do
        given_i_am_viewing_the_patient_registry
        when_i_create_a_new_participant(mrn: '1234')
        then_i_should_see_the_new_participant_in_the_list
      end
    end

    context 'with a non-numerical MRN' do
      scenario 'sees an error message' do
        given_i_am_viewing_the_patient_registry
        when_i_create_a_new_participant(mrn: '1234abc')
        then_i_should_see_an_error_message
      end
    end
  end

  context 'when VALIDATE_MRN is false' do
    let(:validate_mrn) { false }

    context 'with a numerical MRN' do
      scenario 'sees the new Participant in the list' do
        given_i_am_viewing_the_patient_registry
        when_i_create_a_new_participant(mrn: '1234')
        then_i_should_see_the_new_participant_in_the_list
      end
    end

    context 'with a non-numerical MRN' do
      scenario 'sees the new Participant in the list' do
        given_i_am_viewing_the_patient_registry
        when_i_create_a_new_participant(mrn: '1234abc')
        then_i_should_see_the_new_participant_in_the_list
      end
    end
  end

  def given_i_am_viewing_the_patient_registry
    visit participants_path
    expect(page).to have_css('.new-participant')
  end

  def when_i_create_a_new_participant(mrn:)
    find('.new-participant').click

    expect(page).to have_css('.modal.show')

    fill_in 'Last Name', with: 'Potter'
    fill_in 'First Name', with: 'Harry'
    fill_in 'MRN', with: mrn

    bootstrap_datepicker '#participant_date_of_birth', year: Date.current.year, month: 'Mar', day: '15'
    bootstrap_select '#participant_gender', 'Male'
    bootstrap_select '#participant_ethnicity', 'Hispanic or Latino'
    bootstrap_select '#participant_race', 'Asian'

    fill_in 'Address', with: '123 Hogwarts'
    fill_in 'City', with: 'London'
    bootstrap_select '#participant_state', 'South Carolina'
    fill_in 'Zip Code', with: '11111'

    click_button 'Save Participant'
  end

  def then_i_should_see_the_new_participant_in_the_list
    expect(page).to have_no_css('.modal-dialog')

    # Utilizing a case-insensitive regex to bypass CSS text-transformations
    expect(page).to have_css('table.participants tbody tr', text: /Potter/i)
    
    # Now it is 100% safe to query the database
    expect(Participant.count).to eq(1)
  end

  def then_i_should_see_an_error_message
    expect(page).to have_css('#modal_errors', text: 'MRN must only contain numbers', visible: :all)
  end
end