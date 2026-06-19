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

RSpec.describe 'Identity edits services for a particular protocol', type: :system, js: true, inline_jobs: true do
  let(:identity) { @logged_in_identity }
  let(:protocol) { create_and_assign_protocol_without_services_to_me(identity: identity) }
  let!(:arm) { create(:arm_with_visit_groups, protocol: protocol, name: 'Target Arm') }
  let!(:service_to_add) { create(:service, organization: protocol.organization, name: 'Service To Add') }
  let!(:service_to_remove) { create(:service, organization: protocol.organization, name: 'Service To Remove') }
  let!(:line_item) { create(:line_item, arm: arm, service: service_to_remove, protocol: protocol) }

  describe 'adding a service to an arm' do
    it 'should display the new service on the arm' do
      given_i_am_viewing_the_study_schedule
      when_i_open_the_add_service_modal
      and_i_fill_in_the_add_service_form(service_name: service_to_add.name, arm_name: arm.name)
      then_i_should_see_the_service_on_the_arm(service_to_add.name)
    end
  end

  describe 'removing a service from an arm' do
    it 'should successfully remove the service from the arm' do
      given_i_am_viewing_the_study_schedule
      when_i_open_the_remove_service_modal
      and_i_remove_the_service_from_the_arm(service_to_remove.name)
      then_i_should_not_see_the_service_on_the_arm(service_to_remove.name)
    end
  end

  def given_i_am_viewing_the_study_schedule
    visit protocol_path(protocol)

    expect(page).to have_css('div#manage_arms', visible: true)
    expect(page).to have_css('#add_service_button', visible: true)
  end

  def when_i_open_the_add_service_modal
    find('#add_service_button').click
    expect(page).to have_css('.modal-title', text: /Add Service/i, visible: true)
  end

  def when_i_open_the_remove_service_modal
    find('#remove_service_button').click
    expect(page).to have_css('.modal-title', text: /Remove Service/i, visible: true)
  end

  def and_i_fill_in_the_add_service_form(service_name:, arm_name:)
    within('.modal-content', text: /Add Service/i) do
      bootstrap_select('#add_service_id', service_name)
      bootstrap_select('#add_service_arm_ids_and_pages_', arm_name)
      
      # Localized blur, safely clicking the modal header to force the Bootstrap multiselect to close without risking clicking something else on the underlying page.
      find('.modal-header').click

      find('input[type="submit"]').click
    end

    expect(page).to have_no_css('.modal-content', text: /Add Service/i)
  end

  def and_i_remove_the_service_from_the_arm(service_name)
    within('.modal-content', text: /Remove Service/i) do
      bootstrap_select('#line_item_ids', service_name)
      
      find('.modal-header').click

      find('input[type="submit"]').click
    end

    expect(page).to have_no_css('.modal-content', text: /Remove Service/i)
  end

  def then_i_should_see_the_service_on_the_arm(service_name)
    expect(page).to have_css(".arm-#{arm.id}-container", text: /#{Regexp.quote(service_name)}/i, visible: true)
  end

  def then_i_should_not_see_the_service_on_the_arm(service_name)
    expect(page).to have_no_css(".arm-#{arm.id}-container", text: /#{Regexp.quote(service_name)}/i)
  end
end
