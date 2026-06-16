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

require "rails_helper"

RSpec.describe "Identity views Protocols by status", type: :system, js: true do
  let!(:complete_protocol) do
    protocol = create_and_assign_protocol_to_me
    protocol.sub_service_request.update(status: "complete")
    protocol.sparc_protocol.update(short_title: "Slappy")
    protocol
  end

  let!(:draft_protocol) do
    protocol = create_and_assign_protocol_to_me
    protocol.sub_service_request.update(status: "draft")
    protocol.sparc_protocol.update(short_title: "Swanson")
    protocol
  end

  context "when viewing the protocols list" do
    scenario "user filters by complete Protocols" do
      given_i_am_on_the_protocols_page
      when_i_filter_protocols_by_complete_status
      then_i_should_only_see_protocols_in_the_complete_status
    end
  end

  def given_i_am_on_the_protocols_page
    visit protocols_path
    
    expect(page).to have_css("table#protocols", visible: :all)
  end

  def when_i_filter_protocols_by_complete_status
    bootstrap_select('#protocol_status_filter', 'Complete')
  end

  def then_i_should_only_see_protocols_in_the_complete_status
    expect(page).to have_css("table#protocols tbody tr", text: /Slappy/i, visible: :all)

    expect(page).to have_no_css("table#protocols tbody tr", text: /Swanson/i)
  end
end
