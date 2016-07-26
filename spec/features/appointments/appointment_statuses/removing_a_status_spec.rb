require 'rails_helper'

feature 'Removing a Status', js: true do

  context "User removes an appointment status" do
    scenario 'and sees the appointment status is destroyed' do
      given_i_select_an_appointment
      when_i_deselect_an_appointment_status
      then_the_appointment_status_should_be_destroyed_for_that_appointment
    end
  end

  def given_i_select_an_appointment
    protocol      = create_and_assign_protocol_to_me
    participant   = protocol.participants.first
    @appointment  = participant.appointments.first
    visit_group   = @appointment.visit_group

    visit participant_path participant
    wait_for_ajax

    bootstrap_select '#appointment_select', visit_group.name
    wait_for_ajax
  end

  def when_i_deselect_an_appointment_status
    # For fun of course
    bootstrap_select '#appointment_indications', "Skipped Visit"
    find('body').click()
    bootstrap_select '#appointment_indications', "Skipped Visit"
  end

  def then_the_appointment_status_should_be_destroyed_for_that_appointment
    wait_for_ajax
    expect(@appointment.appointment_statuses.size).to eq(0)
  end
end