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

module System
  module VisitHelpers
    # Enforce keyword arguments for explicit state requirements
    def and_the_visit_has_one_grouped_procedure(service:)
      add_a_procedure(service: service, count: 2)
    end

    def add_a_procedure(service:, count: 1)
      # Strict Scoping to prevent false positives across the massive DOM
      within('#appointmentContainer') do
        expect(page).to have_css('.bootstrap-select select.form-control.selectpicker', visible: :hidden)
        
        bootstrap_select('.form-control.selectpicker', service.name)
        fill_in 'service_quantity', with: count
        
        previous_count = all("tr", text: service.name, visible: :all).count

        expect(page).to have_button('addService', disabled: false)
        click_button 'addService'
          
        # Native Capybara polling anticipating hidden group variants
        expect(page).to have_css("tr", text: service.name, minimum: previous_count + 1, visible: :all)
      end
    end

  def given_i_am_viewing_a_visit(participant:, protocol:)
      visit calendar_protocol_participant_path(id: participant.id, protocol_id: protocol.id)
      
      expect(page).to have_css('#appointmentContainer', visible: :all)
      expect(page).to have_css('a.list-group-item.appointment-link')
      
      # Wrap the vulnerable initial click in a StaleElement rescue loop because the calendar framework actively mutates the DOM during initial load.
      retries = 5
      begin
        find('a.list-group-item.appointment-link', match: :first).click
      rescue Selenium::WebDriver::Error::StaleElementReferenceError
        retries -= 1
        retry if retries > 0
        raise "StaleElementReferenceError exhausted targeting the appointment link"
      end
      
      expect(page).to have_button('addService', disabled: :all)
    end

    def given_i_am_viewing_a_started_visit(participant:, protocol:)
      given_i_am_viewing_a_visit(participant: participant, protocol: protocol)
      
      start_btn = find('a.btn.start-appointment, button', text: /Start (Visit|Appointment)/i, match: :first)
      start_btn.click
      
      expect(page).to have_no_css('a.btn.start-appointment')
      expect(page).to have_css('button.complete-appointment', visible: :all)
    end
  end
end
