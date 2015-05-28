require "rails_helper"

feature "Indicating a Status", js: true do

  scenario "User indicates an appointment status" do
    as_a_user_who_selects_an_appointment
    when_I_indicate_an_appointment_status
    an_appointment_status_should_be_created_for_that_appointment
  end

  def as_a_user_who_selects_an_appointment
    create_and_assign_protocol_to_me
    protocol    = Protocol.first
    participant = protocol.participants.first
    @appointment = participant.appointments.first
    visit_group = @appointment.visit_group

    visit participant_path participant
    bootstrap_select '#appointment_select', visit_group.name
  end

  def when_I_indicate_an_appointment_status
    bootstrap_select '#appointment_indications', "Skipped Visit"
    wait_for_ajax
  end

  def an_appointment_status_should_be_created_for_that_appointment
    expect(@appointment.appointment_statuses.size).to eq(1)
  end
end