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

feature 'Identity removes a Procedure', js: true do

  before :each do
    sub_service_request   = create(:sub_service_request_with_organization)
    subsidy               = create(:subsidy, sub_service_request: sub_service_request)
    @protocol              = create(:protocol_imported_from_sparc, sub_service_request: sub_service_request)
    organization_provider = create(:organization_provider, name: "Provider")
    organization_program  = create(:organization_program, name: "Program", parent: organization_provider)
    organization          = sub_service_request.organization
    organization.update_attributes(parent: organization_program, name: "Core")
    create(:clinical_provider, identity: identity, organization: organization)
    create(:project_role_pi, identity: identity, protocol: protocol)
    create(:super_user, identity: identity, organization: organization_provider, billing_manager: true)

    @protocols_participant = @protocol.protocols_participants.first
    @appointment = @protocols_participant.appointments.first
    @services    = @protocol.organization.inclusive_child_services(:per_participant)
  end

  context 'when group has more than 3 members' do
    before :each do
      given_i_am_viewing_a_visit
      when_i_add_3_procedures_to_same_group
    end

    scenario 'and no longer sees the Procedure' do
      when_i_remove_the_first_procedure
      then_i_should_no_longer_see_that_procedure
    end

    scenario 'and sees the group counter decremented' do
      when_i_remove_the_first_procedure
      then_i_should_see_the_group_counter_decrement_by_1
    end

    scenario 'and sees the quantity decremented in the multiselect menu' do
      when_i_remove_the_first_procedure
      then_i_should_see_the_quantity_decremented_in_the_multiselect_menu
    end 
  end

  context 'when group has 2 members' do
    before :each do
      given_i_am_viewing_a_visit
      when_i_add_2_procedures_to_same_group
    end

    scenario 'and no longer sees the group' do
      when_i_remove_the_first_procedure
      then_i_should_no_longer_see_the_group
    end
  end


  def when_i_add_3_procedures_to_same_group
    add_a_procedure @services.first, 3
  end

  def when_i_add_2_procedures_to_same_group
    add_a_procedure @services.first, 2
  end

  def when_i_remove_the_first_procedure
    procedure = Procedure.first

    accept_confirm do
      first('.procedure button.delete').click
    end
    wait_for_ajax
  end

  def then_i_should_no_longer_see_that_procedure
    expect(page).to have_css('.procedure', count: 2)
  end

  def then_i_should_see_the_group_counter_decrement_by_1
    group_id = Procedure.first.group_id

    expect(page).to have_css("tr.procedure-group[data-group-id='#{group_id}'] span.count", text: '2')
  end

  def then_i_should_no_longer_see_the_group
    expect(page).to_not have_css('tr.procedure-group')
  end

  def then_i_should_see_the_quantity_decremented_in_the_multiselect_menu
    find("select#core_multiselect + .btn-group").click
    expect(page).to have_content("2 #{Procedure.first.service_name} R")
  end

end


