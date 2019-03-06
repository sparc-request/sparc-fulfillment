# Copyright © 2011-2018 MUSC Foundation for Research Development~
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

feature 'User views Patient Registry', js: true do

  scenario 'and does not have access' do
    when_i_visit_the_patient_registry
    then_i_should_be_redirected_to_the_home_page
  end

  scenario 'and sees the Patient Registry table' do
    given_i_am_a_patient_registrar
    when_i_visit_the_patient_registry
    then_i_should_see_the_patient_registry
  end


  def given_i_am_not_a_patient_registrar
    create_and_assign_protocol_to_me
    visit participants_path
    wait_for_ajax
  end

  def given_i_am_a_patient_registrar
    create(:patient_registrar, identity: Identity.first, organization: create(:organization))
  end

  def when_i_visit_the_patient_registry
    create_and_assign_protocol_to_me
    visit participants_path
    wait_for_ajax
  end

  def then_i_should_be_redirected_to_the_home_page
    expect(current_path).to eq root_path # gets redirected back to index
  end

  def then_i_should_see_the_patient_registry
    expect(page).to have_css('#patient-registry-table')
  end
end
