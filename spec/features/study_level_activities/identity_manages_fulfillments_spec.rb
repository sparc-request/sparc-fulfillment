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

feature 'Fulfillments', js: true do

  describe 'fulfillments list with components' do
    it 'should list the fulfillments' do
      given_i_have_fulfillments
      and_i_have_opened_up_fulfillments
      
      expect(page).to have_content('Fulfillments List', wait: 5)
      expect(page).to have_content('Components', wait: 5)
    end

    it 'should not show components column when the service does not have components' do
      given_i_have_fulfillments_without_components
      and_i_have_opened_up_fulfillments
      
      expect(page).to have_content('Fulfillments List', wait: 5)
      expect(page).to have_no_content('Components')
    end
  end

  describe 'fulfillment add' do
    it 'should be able to add a fulfillment' do
      given_i_have_fulfillments
      and_i_have_opened_up_fulfillments
      
      add_btn = find('a', text: 'Add Fulfillment', wait: 5)
      add_btn.hover
      add_btn.click
      
      expect(page).to have_css('#fulfillment_fulfilled_at', wait: 5)
      
      when_i_fill_out_the_fulfillment_form
      
      expect(page).to have_content('45.0', wait: 5)
    end

  end

  def given_i_have_fulfillments
    @protocol = create(:protocol_imported_from_sparc)
    @protocol.sparc_protocol.update(type: 'Study')
    org       = @protocol.sub_service_request.organization
    service   = create(:service_with_one_time_fee, organization: org)
    line_item = create(:line_item, protocol: @protocol, service: service)
                create(:fulfillment, line_item: line_item)
                create(:clinical_provider, identity: Identity.first, organization: org)
  end

  def given_i_have_fulfillments_without_components
    @protocol = create(:protocol_imported_from_sparc_no_components)
    @protocol.sparc_protocol.update(type: 'Study')
    org = @protocol.sub_service_request.organization
    service = create(:service_without_components, organization: org)
    line_item = create(:line_item, protocol: @protocol, service: service)
    create(:fulfillment, line_item: line_item)
    create(:clinical_provider, identity: Identity.first, organization: org)
  end

  def and_i_have_opened_up_fulfillments
    visit protocol_path(@protocol.id)
    
    tab_link = find('a', text: 'Non-clinical Services', wait: 5)
    tab_link.hover
    tab_link.click
    
    expect(page).to have_css('.fulfillments a', wait: 5)
    
    fulfill_link = first('.fulfillments a', wait: 5)
    fulfill_link.hover
    fulfill_link.click
  end

  def when_i_fill_out_the_fulfillment_form
    bootstrap_datepicker '#fulfillment_fulfilled_at', day: '15'
    fill_in "fulfillment_quantity", with: "45"
    bootstrap_select '#fulfillment_components', "mo"
    
    save_btn = find_button("Save", wait: 5)
    save_btn.hover
    save_btn.click
  end
end
