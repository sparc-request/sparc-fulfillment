require "rails_helper"

feature "Indicating a Status", js: true do

  context "User indicates an appointment status" do
    scenario 'and sees the appointment status has been created' do
      given_i_select_an_appointment
      when_i_indicate_an_appointment_status
      then_an_appointment_status_should_be_created_for_that_appointment
    end
  end

  def given_i_select_an_appointment
    protocol      = create_and_assign_protocol_to_me
    participant   = protocol.participants.first
    @appointment  = participant.appointments.first
    visit_group   = @appointment.visit_group

    visit participant_path participant
    bootstrap_select '#appointment_select', visit_group.name
  end

  def when_i_indicate_an_appointment_status
    bootstrap_select '#appointment_indications', "Skipped Visit"
    wait_for_ajax
  end

  def then_an_appointment_status_should_be_created_for_that_appointment
    expect(@appointment.appointment_statuses.size).to eq(1)
  end
end