require 'rails_helper'

feature 'Identity uncompletes an appointment', js: true do

  scenario 'and sees the completed date reset' do
    given_i_have_added_a_procedure_to_an_appointment
    when_i_begin_the_appointment
    when_i_complete_the_procedure
    and_i_complete_the_appointment
    when_i_uncomplete_the_appointment
    then_i_should_see_the_appointment_is_uncomplete
  end

  def given_i_have_added_a_procedure_to_an_appointment
    protocol    = create_and_assign_protocol_to_me
    @participant = protocol.participants.first
    visit_group = @participant.appointments.first.visit_group
    service     = protocol.organization.inclusive_child_services(:per_participant).first

    visit participant_path(@participant)
    bootstrap_select '#appointment_select', visit_group.name
    bootstrap_select '#service_list', service.name
    fill_in 'service_quantity', with: 1
    find('button.add_service').click
    wait_for_ajax
  end

  def when_i_begin_the_appointment
    find('button.start_visit').click
  end

  def when_i_complete_the_procedure
    find('label.status.complete').click
    wait_for_ajax
  end

  def and_i_complete_the_appointment
    find('button.complete_visit').click
    wait_for_ajax
  end

  def when_i_uncomplete_the_appointment
    find('button.uncomplete_visit').click
    wait_for_ajax
  end

  def then_i_should_see_the_appointment_is_uncomplete
    expect(page).to have_css('button.complete_visit', visible: true)
    expect(page).to have_css('div.completed_date_input.hidden', visible: false)
  end
end

