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

require "rails_helper"

feature "Identity views protocol", js: true do

  scenario "that has no Services" do
    given_i_am_a_fulfillment_provider_for_a_protocol_without_services
    when_i_visit_the_protocol_page
    then_i_should_not_see_service_related_elements
  end

  scenario "and sees that the Current IRB Expiration Date is correctly formatted" do
    given_i_am_a_fulfillment_provider_for_a_protocol
    when_i_visit_the_protocol_page
    then_i_should_see_a_correctly_formatted_irb_expiration_date
  end

  def given_i_am_a_fulfillment_provider_for_a_protocol
    @protocol = create_and_assign_protocol_to_me
  end

  def given_i_am_a_fulfillment_provider_for_a_protocol_without_services
    @protocol = create_and_assign_protocol_without_services_to_me
  end

  def when_i_visit_the_protocol_page
    visit protocol_path(@protocol.id)
    wait_for_ajax
  end

  def then_i_should_see_a_correctly_formatted_irb_expiration_date
    expect(page).to have_css(".irb_expiration_date", text: /\d\d\/\d\d\/\d\d/)
  end

  def then_i_should_not_see_service_related_elements
    expect(page).to_not have_css("div[role='tabpanel'] a", text: "Study Schedule")
    expect(page).to_not have_css("div[role='tabpanel'] a", text: "Participant List")
    expect(page).to_not have_css("div[role='tabpanel'] a", text: "Participant Tracker")
    expect(page).to_not have_css("#study_schedule_buttons")
    expect(page).to_not have_css("#study_schedule_tabs")
  end
end
