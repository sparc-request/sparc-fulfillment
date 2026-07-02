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

RSpec.describe 'Identity views additional columns', type: :system, js: true do
  let(:protocol) { create_and_assign_protocol_to_me }

  context 'when viewing the protocols index table' do
    scenario 'user adds the organizations column via the column toggle dropdown' do
      given_i_am_on_the_protocols_index_page
      when_i_select_organizations_from_the_dropdown
      then_i_should_see_the_organizations_column
    end
  end

  def given_i_am_on_the_protocols_index_page
    visit protocols_path
    
    expect(page).to have_css('.bootstrap-table', visible: :all)
  end

  def when_i_select_organizations_from_the_dropdown
    within('.bootstrap-table') do
      find('.keep-open').click
      
      expect(page).to have_css('.dropdown-menu.show', visible: true)
      
      # Bypass CSS pointer-event traps by directly targeting the input and forcing the JS property to update natively
      checkbox = find("input[data-field='organizations']", visible: :all)
      checkbox.set(true)
       
      find('.keep-open').click
      expect(page).to have_no_css('.dropdown-menu.show')
    end
  end

  def then_i_should_see_the_organizations_column
    expect(page).to have_css('.bootstrap-table th', text: /Provider\/Program\/Core/i, visible: :all)
  end
end