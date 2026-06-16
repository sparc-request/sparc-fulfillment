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

RSpec.describe "Identity views protocol", type: :system, js: true do

  context "when the protocol has no services" do
    let!(:protocol) { create_and_assign_protocol_without_services_to_me }

    scenario "user does not see service-related elements" do
      when_i_visit_the_protocol_page(protocol)
      then_i_should_not_see_service_related_elements(protocol)
    end
  end

  context "when the protocol has services" do
    let!(:protocol) { create_and_assign_protocol_to_me }

    scenario "user sees that the Current IRB Expiration Date is correctly formatted" do
      when_i_visit_the_protocol_page(protocol)
      then_i_should_see_a_correctly_formatted_irb_expiration_date
    end
  end

  def when_i_visit_the_protocol_page(protocol)
    visit protocol_path(protocol.id)
    
    expect(page).to have_current_path(protocol_path(protocol.id), ignore_query: true)
  end

  def then_i_should_see_a_correctly_formatted_irb_expiration_date
    # Upgraded Regex to \d{2} syntax for strict layout matching (e.g., 12/31/2026)
    expect(page).to have_css(".irb-expiration", text: /\d{2}\/\d{2}\/\d{2,4}/)
  end

  def then_i_should_not_see_service_related_elements(protocol)
    # We must wait for the page content to natively render BEFORE asserting absence - otherwise Capybara checks a white screen, finds nothing, and falsely passes
    expect(page).to have_css(".irb-expiration", visible: :all)

    expect(page).to have_no_css("div[role='tabpanel'] a", text: "Study Schedule")
    expect(page).to have_no_css("div[role='tabpanel'] a", text: "Participant List")
    expect(page).to have_no_css("div[role='tabpanel'] a", text: "Participant Tracker")
    expect(page).to have_no_css("#study_schedule_buttons")
    expect(page).to have_no_css("#study_schedule_tabs")
  end
end
