require 'rails_helper'

feature 'Identity resets appointment', js: true do
  scenario 'the appointment is completed, but is then reset' do
    given_i_have_resolved_all_procedures_on_an_appointment_and_completed_the_appointment
    and_i_click_the_reset_button
    i_should_see_a_reset_appointment
  end

  def given_i_have_resolved_all_procedures_on_an_appointment_and_completed_the_appointment
    protocol = create_and_assign_protocol_to_me
    participant = protocol.participants.first
    visit_group = participant.appointments.first.visit_group\

    appointment = participant.appointments.first
    appointment.update_attributes(start_date: Time.now, completed_date: Time.now.tomorrow)

    service = protocol.organization.inclusive_child_services(:per_participant).first
    procedure = create(:procedure_complete, appointment_id: appointment.id, service_name: service.name, service_id: service.id, visit_id: appointment.visit_group.visits.first.id, sparc_core_name: service.organization.name)
    visit participant_path participant
    bootstrap_select '#appointment_select', visit_group.name
    wait_for_ajax
  end

  def and_i_click_the_reset_button
  end

  def i_should_see_a_reset_appointment
  end
end
