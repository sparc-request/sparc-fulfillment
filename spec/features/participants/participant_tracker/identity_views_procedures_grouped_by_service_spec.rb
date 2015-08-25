require 'rails_helper'

feature 'Identity views Procedures grouped by Service', js: true do

  scenario 'after selecting an Appointment' do
    given_i_am_viewing_a_participants_calendar
    when_i_select_an_appointment
    then_i_should_see_a_grouped_services_row
  end

  def given_i_am_viewing_a_participants_calendar
    create(:identity)
    protocol = create_and_assign_protocol_with_duplicate_services_to_me
    participant = Participant.first
    visit participant_path(participant)
  end

  def when_i_select_an_appointment
    appointment = Appointment.first

    bootstrap_select '#appointment_select', appointment.name
  end

  def then_i_should_see_a_grouped_services_row
    expect(page).to have_css('table.procedures tbody tr.grouped_services_row')
  end
end
