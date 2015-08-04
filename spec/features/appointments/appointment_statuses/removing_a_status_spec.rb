require 'rails_helper'

feature 'Removing a Status', js: true do

  scenario "User removes an appointment status" do
    as_a_user_who_selects_an_appointment
    when_I_deselect_an_appointment_status
    the_appointment_status_should_be_destroyed_for_that_appointment
  end

  def as_a_user_who_selects_an_appointment
    protocol      = create_and_assign_protocol_to_me
    participant   = protocol.participants.first
    @appointment  = participant.appointments.first
    visit_group   = @appointment.visit_group

    visit participant_path participant
    bootstrap_select '#appointment_select', visit_group.name
  end

  def when_I_deselect_an_appointment_status
    # For fun of course
    bootstrap_select '#appointment_indications', "Skipped Visit"
    find('body').click()
    bootstrap_select '#appointment_indications', "Skipped Visit"
  end

  def the_appointment_status_should_be_destroyed_for_that_appointment
    wait_for_ajax
    expect(@appointment.appointment_statuses.size).to eq(0)
  end
end