# Copyright © 2011-2016 MUSC Foundation for Research Development~
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

feature 'User views procedure which has an unavailable service', js: true do

	scenario 'and sees the inactive tag.' do
		given_i_am_viewing_the_appointment_calendar
		when_the_participant_has_a_procedure_with_an_inactive_service
		when_i_open_the_appointment_calendar_with_the_bad_procedure
		then_i_should_see_the_inactive_tag
	end

	def given_i_am_viewing_the_appointment_calendar
		protocol 		= create_and_assign_protocol_to_me
		@participant = protocol.participants.first

		visit participant_path(@participant)
		wait_for_ajax
	end

	def when_the_participant_has_a_procedure_with_an_inactive_service
		service     = Service.first
		@appointment = @participant.appointments.first

		service.update_attributes(is_available: false)

		create(:procedure, appointment: @appointment, service: service)
	end

	def when_i_open_the_appointment_calendar_with_the_bad_procedure
		visit_group_name = @appointment.visit_group.name

		bootstrap_select '#appointment_select', visit_group_name
	end

	def then_i_should_see_the_inactive_tag
		expect(page).to have_text("(Inactive)")
	end
end
