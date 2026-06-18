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

RSpec.describe 'Identity manages Fulfillments', type: :system, js: true do
  # Rule I: Eager/Lazy bindings at the top of the file. 
  # We establish the data dependencies clearly for both the standard and the no-component variants.
  let(:protocol)  { create(:protocol_imported_from_sparc) }
  let(:org)       { protocol.sub_service_request.organization }
  let(:service)   { create(:service_with_one_time_fee, organization: org) }
  let(:line_item) { create(:line_item, protocol: protocol, service: service) }

  let(:protocol_no_comp)  { create(:protocol_imported_from_sparc_no_components) }
  let(:org_no_comp)       { protocol_no_comp.sub_service_request.organization }
  let(:service_no_comp)   { create(:service_without_components, organization: org_no_comp) }
  let(:line_item_no_comp) { create(:line_item, protocol: protocol_no_comp, service: service_no_comp) }

  describe 'fulfillments list with components' do
    it 'should list the fulfillments' do
      given_i_have_fulfillments
      and_i_have_opened_up_fulfillments(protocol)
      
      expect(page).to have_css('.modal-title', text: /Fulfillments List/i, visible: true)
      expect(page).to have_content('Components')
    end
  end

  describe 'fulfillments list without components' do
    it 'should not show components column when the service does not have components' do
      given_i_have_fulfillments_without_components
      and_i_have_opened_up_fulfillments(protocol_no_comp)
      
      expect(page).to have_css('.modal-title', text: /Fulfillments List/i, visible: true)
      expect(page).to have_no_content('Components')
    end
  end

  describe 'fulfillment add' do
    it 'should be able to add a fulfillment' do
      given_i_have_fulfillments
      and_i_have_opened_up_fulfillments(protocol)

      expect(page).to have_css('.modal-title', text: /Fulfillments List/i, visible: true)
      click_link "Add Fulfillment"
      
      expect(page).to have_css('#fulfillment_fulfilled_at', visible: :all)
      
      when_i_fill_out_the_fulfillment_form
      
      expect(page).to have_css('td.qty', text: '45.0')
    end
  end

  def given_i_have_fulfillments
    protocol.sparc_protocol.update(type: 'Study')
    create(:fulfillment, line_item: line_item)
    
    # Explicitly binding records to the active Devise session
    create(:clinical_provider, identity: @logged_in_identity, organization: org)
  end

  def given_i_have_fulfillments_without_components
    protocol_no_comp.sparc_protocol.update(type: 'Study')
    create(:fulfillment, line_item: line_item_no_comp)
    create(:clinical_provider, identity: @logged_in_identity, organization: org_no_comp)
  end

  def and_i_have_opened_up_fulfillments(protocol)
    visit protocol_path(protocol)

    expect(page).to have_content('Manage Arms')

    expect(page).to have_css('.nav-link', text: /Non-clinical Services/i)
    click_link "Non-clinical Services"

    expect(page).to have_css('.fulfillments', visible: true)
    find('.fulfillments a', match: :first).click
    
    expect(page).to have_css('.modal-content', visible: true)
  end

  def when_i_fill_out_the_fulfillment_form
    bootstrap_datepicker '#fulfillment_fulfilled_at', day: '15', text: '06/15/2026'
    
    fill_in "fulfillment_quantity", with: "45"
    bootstrap_select '#fulfillment_components', "mo"
    click_button "Save"
    
    expect(page).to have_no_css('.modal-title', text: /Create New Fulfillment/i)
  end
end
