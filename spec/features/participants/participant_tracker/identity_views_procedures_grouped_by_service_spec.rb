require 'rails_helper'

feature 'Identity views Procedures grouped by Service', js: true do

  scenario 'and sees that single Services are not grouped' do
    given_an_appointment_with_a_single_service
    when_i_view_the_participants_calendar
    then_i_should_see_a_non_grouped_services_row
  end

  scenario 'and sees that duplicate Services are grouped' do
    given_an_appointment_with_duplicate_services
    when_i_view_the_participants_calendar
    then_i_should_see_a_grouped_services_row
  end

  scenario 'and sees that duplicate Services are not grouped after updating R/T' do
    given_an_appointment_with_duplicate_services
    when_i_view_the_participants_calendar
    and_i_update_a_grouped_procedure_rt_out_of_the_group
    then_i_should_not_see_grouped_service_row
  end

  scenario 'and sees that duplicate Services are grouped after updating R/T' do
    given_an_appointment_with_a_single_service
    when_i_view_the_participants_calendar
    and_i_update_a_grouped_procedure_rt_into_the_group
    then_i_should_see_a_grouped_services_row
  end

  def given_an_appointment_with_a_single_service
    create(:identity)
    protocol = protocol_with_single_service
    participant = Participant.first
    visit participant_path(participant)
  end

  def given_an_appointment_with_duplicate_services
    create(:identity)
    create_and_assign_protocol_with_duplicate_services
  end

  def when_i_view_the_participants_calendar
    participant = Participant.first
    appointment = Appointment.first

    visit participant_path(participant)
    bootstrap_select '#appointment_select', appointment.name
  end

  def when_i_select_an_appointment_with_single_services
    appointment = Appointment.first

    bootstrap_select '#appointment_select', appointment.name
  end

  def when_i_update_a_grouped_procedures_rt

  end

  def then_i_should_see_a_grouped_services_row
    expect(page).to have_css('table.procedures tbody tr.grouped_services_row table.accordian')
  end

  def then_i_should_see_a_non_grouped_services_row
    expect(page).to_not have_css('table.procedures tbody > tr.procedure')
  end

  def then_i_should_not_see_grouped_service_row

  end
end
