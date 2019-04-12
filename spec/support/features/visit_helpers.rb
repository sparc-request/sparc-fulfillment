# Copyright © 2011-2019 MUSC Foundation for Research Development~
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
      2.times { add_a_procedure @services.first }
    end

    def add_a_procedure(service, count = 1)
      bootstrap_select '#service_list', service.name
      fill_in 'service_quantity', with: count
      find('button.add_service').click
      wait_for_ajax
    end

    def given_i_am_viewing_a_visit
      visit calendar_participants_path(participant_id: @protocols_participant.participant_id, protocols_participant_id: @protocols_participant.id, protocol_id: @protocol.id)
      wait_for_ajax

      bootstrap_select '#appointment_select', @appointment.name
      wait_for_ajax
    end

    def given_i_am_viewing_a_started_visit
      visit calendar_participants_path(participant_id: @protocols_participant.participant_id, protocols_participant_id: @protocols_participant.id, protocol_id: @protocol.id)
      wait_for_ajax

      bootstrap_select '#appointment_select', @appointment.name
      wait_for_ajax
      
      find('button.start_visit').click
      wait_for_ajax
    end
  end
end
