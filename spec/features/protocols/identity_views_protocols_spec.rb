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

feature 'Identity views protocols', js: true do

  scenario 'and sees Protocols for which they are a Fulfillment Provider for' do
    given_i_am_a_fulfillment_provider_for_a_protocol
    when_i_visit_the_protocols_page
    then_i_should_see_protocols_for_which_i_am_a_filfillment_provider
  end

  scenario 'and does not see Protocols for which they are not a Fulfillment Provider for' do
    given_i_am_not_a_fulfillment_provider_for_a_protocol
    when_i_visit_the_protocols_page
    then_i_should_not_see_protocols_for_which_i_am_not_a_filfillment_provider
    and_i_should_not_be_able_to_access_protocols_for_which_i_am_not_a_filfillment_provider
  end

  scenario 'and sees Coordinators' do
    given_i_am_a_fulfillment_provider_for_a_protocol
    when_i_visit_the_protocols_page
    and_i_click_on_the_coordinators_dropdown
    then_i_should_see_a_list_of_coordinators
  end

  scenario 'and sees changes made by other Identitys in realtime' do
    given_i_am_a_fulfillment_provider_for_a_protocol
    when_i_visit_the_protocols_page
    and_a_change_is_made_to_the_protocol_by_another_identity
    then_i_should_see_the_change
  end

  def given_i_am_a_fulfillment_provider_for_a_protocol
    create_and_assign_protocol_to_me
  end

  def given_i_am_not_a_fulfillment_provider_for_a_protocol
    organization            = create(:organization)
    sub_service_request     = create(:sub_service_request, organization: organization)
    @unauthorized_protocol  = create(:protocol, sub_service_request: sub_service_request)
  end

  def when_i_visit_the_protocols_page
    visit protocols_path
    wait_for_ajax
  end

  def and_i_click_on_the_coordinators_dropdown
    page.find('table.protocols tbody tr:first-child td.coordinators button').click
  end

  def and_a_change_is_made_to_the_protocol_by_another_identity
    Protocol.first.sparc_protocol.update_attribute :short_title, 'Test 123'
    refresh_bootstrap_table('table.protocols')
  end

  def then_i_should_see_protocols_for_which_i_am_a_filfillment_provider
    expect(page).to have_css("table.protocols tbody tr td.short_title", count: 1)
  end

  def then_i_should_not_see_protocols_for_which_i_am_not_a_filfillment_provider
    expect(page).to have_css("table.protocols tbody tr", text: "No matching records found")
  end

  def and_i_should_not_be_able_to_access_protocols_for_which_i_am_not_a_filfillment_provider
    visit protocol_path(@unauthorized_protocol.id) # tries to visit protocol without access
    wait_for_ajax
    
    expect(current_path).to eq root_path # gets redirected back to index
  end

  def then_i_should_see_a_list_of_coordinators
    expect(page).to have_css('table.protocols tr:first-child td.coordinators ul.dropdown-menu')
  end

  def then_i_should_see_the_change
    expect(page).to have_css('table.protocols td.short_title', text: 'Test 123')
  end
end

