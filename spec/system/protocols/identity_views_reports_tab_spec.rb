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

RSpec.describe 'Identity views Reports tab', type: :system, js: true, inline_jobs: true do
  let(:protocol) { create_and_assign_protocol_to_me }

  context 'when generating and viewing Protocol reports' do
    scenario 'sees a list of Protocol reports' do
      visit protocol_path(protocol)

      expect(page).to have_button('Export')
      click_button 'Export'

      expect(page).to have_css('.reports-tab-badge')

      find('#reportsTabLink').click

      within('table.protocol_reports') do
        expect(page).to have_css('tbody td.title', text: /Study Schedule Report/i)
      end
    end
  end

  context 'when generating and viewing Participant reports' do
    scenario 'sees a list of Participant reports' do
      visit protocol_path(protocol)

      expect(page).to have_content('Manage Arms')

      click_link 'Participant Tracker'

      expect(page).to have_css('#participantTrackerTable', visible: :all)
      expect(page).to have_css('.participant-report', visible: true)
      
      find('.participant-report').click
      expect(page).to have_css('.reports-tab-badge')

      find('#reportsTabLink').click

      within('table.protocol_reports') do
        expect(page).to have_css('tbody td.title', text: /Participant Report/i)
      end
    end
  end
end
