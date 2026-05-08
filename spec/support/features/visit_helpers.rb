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

module Features
  module VisitHelpers

    def and_the_visit_has_one_grouped_procedure
      add_a_procedure(@services.first, 2)
    end

    def add_a_procedure(service, count = 1)
      expect(page).to have_css('button#addService', visible: true)
      
      # HYDRATION BUFFER: Allow Rails 7 JS controllers 200ms to bind to the pane
      sleep 0.2

      bootstrap_select('.form-control.selectpicker', service.name)
      fill_in 'service_quantity', with: count
      
      previous_count = all(".core tbody tr", text: service.name, visible: :all).count

      retries = 0
      begin
        find('button#addService').click
        
        expect(page).to have_css(".core tbody tr", text: service.name, minimum: previous_count + 1, visible: :all, wait: 4)
        
      rescue RSpec::Expectations::ExpectationNotMetError => e
        retry if (retries += 1) < 2
        raise e
      end
    end

    def given_i_am_viewing_a_visit
      visit calendar_protocol_participant_path(id: @protocols_participant.id, protocol_id: @protocol)
      
      expect(page).to have_css('a.list-group-item.appointment-link')
      first('a.list-group-item.appointment-link').click
      
      expect(page).to have_css('button#addService', visible: true)
    end

    def given_i_am_viewing_a_started_visit
      given_i_am_viewing_a_visit 
      
      start_btn = find('a.btn.start-appointment, button', text: /Start (Visit|Appointment)/i, match: :first)
      start_btn.click
      
      expect(page).to have_no_css('a.btn.start-appointment')
      expect(page).to have_css('button.complete-appointment', visible: true)
    end
    
  end
end
