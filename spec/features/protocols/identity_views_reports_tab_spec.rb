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

feature 'Identity views Report tab', js: true, enqueue: false do
  scenario 'and sees a list of Protocol reports' do
    protocol = create_data
    visit protocol_path(protocol)

    export_btn = find_button("Export", wait: 5)
    
    export_btn.hover
    export_btn.click

    reports_tab = find('#reportsTabLink', wait: 5)
    reports_tab.hover
    reports_tab.click

    expect(page).to have_css('table.protocol_reports tbody td.title', count: 1, wait: 5)
  end

  scenario 'and sees a list of Participant reports' do
    protocol = create_data
    protocols_participant = protocol.protocols_participants.first
    visit protocol_path(protocol)

    tracker_tab = find_link('Participant Tracker', wait: 5)
    tracker_tab.hover
    tracker_tab.click

    report_btn = find('.participant-report', wait: 5)
    report_btn.hover
    report_btn.click

    reports_tab = find('#reportsTabLink', wait: 5)
    reports_tab.hover
    reports_tab.click

    expect(page).to have_css('table.protocol_reports tbody td.title', count: 1, wait: 5)
  end

  private

  def create_data
    identity = Identity.first
    sub_service_request = create(:sub_service_request_with_organization)
    protocol = create(:protocol_imported_from_sparc, sub_service_request: sub_service_request)
    organization_provider = create(:organization_provider)
    organization_program = create(:organization_program, parent: organization_provider)
    organization = sub_service_request.organization
    organization.update(parent: organization_program, name: "Core")
    create(:clinical_provider, identity: identity, organization: organization)
    create(:project_role_pi, identity: identity, protocol: protocol)
    protocol
  end
end
