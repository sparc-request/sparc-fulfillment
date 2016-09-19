# Copyright © 2011-2016 MUSC Foundation for Research Development~
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

feature 'Delete Procedure', js: true do

  context 'User deletes a core' do
    scenario 'and does not see the core' do
      given_i_am_viewing_a_core_with_n_procedures_such_that_n_is '1'
      when_i_delete_the_first_procedure
      then_i_should_not_see_the_core
    end
  end

  context 'User deletes a procedure but not a core' do
    scenario 'and does not see the procedure' do
      given_i_am_viewing_a_core_with_n_procedures_such_that_n_is '2'
      when_i_delete_the_first_procedure
      then_i_should_not_see_the_first_procedure
    end
  end

  def given_i_am_viewing_a_core_with_n_procedures_such_that_n_is number_of_procedures
    protocol      = create_and_assign_protocol_to_me
    participant   = protocol.participants.first
    visit_group   = participant.appointments.first.visit_group
    service       = protocol.organization.inclusive_child_services(:per_participant).first

    visit participant_path participant
    wait_for_ajax

    bootstrap_select('#appointment_select', visit_group.name)
    wait_for_ajax
    
    bootstrap_select '#service_list', service.name
    fill_in 'service_quantity', with: number_of_procedures
    find('button.add_service').trigger('click')
    wait_for_ajax
  end

  def when_i_delete_the_first_procedure
    accept_confirm do
      first('.procedure button.delete').click
    end
    wait_for_ajax
  end

  def then_i_should_not_see_the_core
    expect(page).to have_css('.cores .core', count: 0)
  end

  def then_i_should_not_see_the_first_procedure
    expect(page).to have_css('.procedures .procedure', count: 1)
  end

end
