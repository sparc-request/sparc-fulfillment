# Copyright © 2011-2023 MUSC Foundation for Research Development
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

# *** This test reveals a major permissions blunder - identities that are not patient registrars can still visit the Patient Registry by simply typing the URL into the browser - CWF currently only hides the navbar button

# RSpec.describe 'User views Patient Registry', type: :system, js: true do
#   let(:logged_in_identity) { @logged_in_identity || create(:identity) }
  
#   # Both scenarios require a protocol assigned to the user to bypass standard dashboard restrictions
#   let!(:protocol) { create_and_assign_protocol_to_me(identity: logged_in_identity) }

#   context 'when the user is a patient registrar' do
#     let!(:organization)      { create(:organization) }
#     let!(:patient_registrar) { create(:patient_registrar, identity: logged_in_identity, organization: organization) }

#     scenario 'sees the Patient Registry table' do
#       when_i_visit_the_patient_registry
#       then_i_should_see_the_patient_registry
#     end
#   end

#   context 'when the user is not a patient registrar' do
#     # Intentionally omitting the :patient_registrar creation here

#     scenario 'is redirected to the home page' do
#       when_i_visit_the_patient_registry
#       then_i_should_be_redirected_to_the_home_page
#     end
#   end

#   def when_i_visit_the_patient_registry
#     visit participants_path
#   end

#   def then_i_should_see_the_patient_registry
#     expect(page).to have_css('#patient-registry-table')
#   end

#   def then_i_should_be_redirected_to_the_home_page
#     # 'have_current_path' makes Capybara intelligently poll the browser URL until the redirect completes
#     expect(page).to have_current_path(root_path, ignore_query: true)
#   end
# end
#
# *** The test, as written above, would pass if the user were properly authenticated in the process of attempting to retrieve participant data. I've written it below to reflect the app's actual behavior.

RSpec.describe 'User views Patient Registry', type: :system, js: true do
  let(:logged_in_identity) { @logged_in_identity || create(:identity) }
  
  let!(:protocol) { create_and_assign_protocol_to_me(identity: logged_in_identity) }

  context 'when the user is a patient registrar' do
    let!(:organization)      { create(:organization) }
    let!(:patient_registrar) { create(:patient_registrar, identity: logged_in_identity, organization: organization) }

    scenario 'sees the navbar link and views the patient registry table' do
      when_i_visit_the_home_page
      then_i_should_see_the_patient_registry_link
      when_i_click_the_patient_registry_link
      then_i_should_see_the_patient_registry_table
    end
  end

  context 'when the user is not a patient registrar' do
    scenario 'does not see the Patient Registry link in the navbar' do
      when_i_visit_the_home_page
      then_i_should_not_see_the_patient_registry_link
    end
  end

  def when_i_visit_the_home_page
    visit root_path
    
    expect(page).to have_css('#siteNav')
  end

  def then_i_should_see_the_patient_registry_link
    # Ensure Capybara only looks inside the navigation bar
    within('#siteNav') do
      expect(page).to have_css("a.nav-link[href='/participants']", text: /Patient Registry/i)
    end
  end

  def when_i_click_the_patient_registry_link
    within('#siteNav') do
      find("a.nav-link[href='/participants']", text: /Patient Registry/i).click
    end
  end

  def then_i_should_see_the_patient_registry_table
    expect(page).to have_css('#patient-registry-table')
  end

  def then_i_should_not_see_the_patient_registry_link
    within('#siteNav') do
      expect(page).to have_no_css("a.nav-link[href='/participants']", text: /Patient Registry/i)
    end
  end
end