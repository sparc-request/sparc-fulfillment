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

RSpec.describe 'Identity views protocols', type: :system, js: true do
  
  context 'when the user is a Fulfillment Provider for a protocol' do
    let!(:protocol) { create_and_assign_protocol_to_me }

    scenario 'they see the protocols for which they are a provider' do
      given_i_am_on_the_protocols_page
      then_i_should_see_my_protocol(protocol)
    end

    scenario 'they can view Coordinators via the table dropdown' do
      given_i_am_on_the_protocols_page
      when_i_click_on_the_coordinators_dropdown_for(protocol)
      then_i_should_see_a_list_of_coordinators
    end

    scenario 'they see changes made by other identities in real-time after a refresh' do
      given_i_am_on_the_protocols_page
      when_another_identity_changes_the_protocol(protocol)
      then_i_should_see_the_updated_protocol_title
    end
  end

  context 'when the user is NOT a Fulfillment Provider for a protocol' do
    let!(:unauthorized_protocol) do
      organization = create(:organization)
      sub_service_request = create(:sub_service_request, organization: organization)
      create(:protocol, sub_service_request: sub_service_request)
    end

    scenario 'they cannot see or access the unauthorized protocol' do
      given_i_am_on_the_protocols_page
      then_i_should_not_see_the_unauthorized_protocol(unauthorized_protocol)
      and_i_should_not_be_able_to_access_the_unauthorized_protocol_directly(unauthorized_protocol)
    end
  end

  def given_i_am_on_the_protocols_page
    visit protocols_path
    
    expect(page).to have_css('table#protocols', visible: :all)
  end

  def then_i_should_see_my_protocol(protocol)
    short_title = Regexp.quote(protocol.sparc_protocol.short_title)
    expect(page).to have_css('table#protocols tbody tr td.short-title', text: /#{short_title}/i, visible: :all)
  end

  def when_i_click_on_the_coordinators_dropdown_for(protocol)
    short_title = Regexp.quote(protocol.sparc_protocol.short_title)
    
    within('table#protocols tbody tr', text: /#{short_title}/i, match: :first) do
      find('td.coordinators button').click
      
      expect(page).to have_css('.dropdown-menu.show', visible: true)
    end
  end

  def then_i_should_see_a_list_of_coordinators
    expect(page).to have_css('.coordinators .dropdown-menu.show', visible: :all)
  end

  def when_another_identity_changes_the_protocol(protocol)
    protocol.sparc_protocol.update!(short_title: 'Test 123')
    
    refresh_bootstrap_table('.bootstrap-table')
  end

  def then_i_should_see_the_updated_protocol_title
    expect(page).to have_css('table#protocols td.short-title', text: /Test 123/i, visible: :all)
  end

  def then_i_should_not_see_the_unauthorized_protocol(unauthorized_protocol)
    short_title = Regexp.quote(unauthorized_protocol.sparc_protocol.short_title)
    
    expect(page).to have_css('table#protocols tbody', visible: :all)
    
    expect(page).to have_no_css('table#protocols tbody tr', text: /#{short_title}/i)
    
    expect(page).to have_css('table#protocols tbody tr', text: /No matching records found/i, visible: :all)
  end

  def and_i_should_not_be_able_to_access_the_unauthorized_protocol_directly(unauthorized_protocol)
    visit protocol_path(unauthorized_protocol.id)
    
    expect(page).to have_current_path(root_path, ignore_query: true)
  end
end

