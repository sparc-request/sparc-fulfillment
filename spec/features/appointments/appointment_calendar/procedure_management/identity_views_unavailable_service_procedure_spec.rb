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
