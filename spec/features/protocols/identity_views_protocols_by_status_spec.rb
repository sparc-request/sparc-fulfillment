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

feature "Identity views Protocols by status", js: true do

  scenario "and filters by complete Protocols" do
    given_i_am_a_fulfillment_provider_for_a_protocol
    when_i_visit_the_protocols_page
    and_i_filter_protocols_by_complete_status
    then_i_should_only_see_protocols_in_the_complete_status
  end

  def given_i_am_a_fulfillment_provider_for_a_protocol
    2.times { create_and_assign_protocol_to_me }

    Protocol.first.sub_service_request.update_attributes(status: "complete")
    Protocol.first.sparc_protocol.update_attributes(short_title: "Slappy")
    Protocol.last.sub_service_request.update_attributes(status: "draft")
    Protocol.last.sparc_protocol.update_attributes(short_title: "Swanson")
  end

  def when_i_visit_the_protocols_page
    visit protocols_path
    wait_for_ajax
  end

  def and_i_filter_protocols_by_complete_status
    bootstrap_select '#index_selectpicker', 'Complete'
    wait_for_ajax
  end

  def then_i_should_only_see_protocols_in_the_complete_status
    expect(page.body).to have_css("table#protocol-list", text: "Slappy")
    expect(page.body).to_not have_css("table#protocol-list", text: "Swanson")
  end
end
