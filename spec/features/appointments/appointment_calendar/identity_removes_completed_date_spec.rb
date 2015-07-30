require 'rails_helper'

feature 'identity removes complete date' , js: true do

  scenario 'the completed date exsists but the user clicks to remove it' do
    given_i_have_completed_all_procedures_on_an_appointment_and_completed_the_appointment
    when_i_clear_the_complete_date_for_the_visit
    then_i_should_no_longer_see_the_input_field_for_the_complete_date
  end

  def given_i_have_completed_all_procedures_on_an_appointment_and_completed_the_appointment
    protocol    = create_and_assign_protocol_to_me
    participant = protocol.participants.first
    visit_group = participant.appointments.first.visit_group\

    appointment = participant.appointments.first
    appointment.update_attributes(start_date: Time.now, completed_date: Time.now.tomorrow)

    service     = protocol.organization.inclusive_child_services(:per_participant).first
    procedure   = create(:procedure_complete, appointment_id: appointment.id, service_name: service.name, service_id: service.id, visit_id: appointment.visit_group.visits.first.id, sparc_core_name: service.organization.name)
    visit participant_path participant
    bootstrap_select '#appointment_select', visit_group.name
    wait_for_ajax
  end

  def when_i_clear_the_complete_date_for_the_visit
    find("#complete_appointment_date_remove").click
  end

  def then_i_should_no_longer_see_the_input_field_for_the_complete_date
    expect(page).to have_css ".completed_date_btn"
  end

end
