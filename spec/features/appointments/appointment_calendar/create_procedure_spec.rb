require 'rails_helper'

feature 'Create Procedure', js: true do

  scenario 'User adds a single Procedure to Visit' do
    given_i_am_viewing_a_participant
    and_i_add_a_procedure
    then_i_should_see_the_procedure_in_the_appointment_calendar
  end

  scenario 'User adds multiple Procedures to Visit' do
    given_i_am_viewing_a_participant
    and_i_add_two_procedures
    then_i_should_see_two_procedures_in_the_appointment_calendar
  end

  def given_i_am_viewing_a_participant
    create_and_assign_protocol_to_me
    @protocol     = Protocol.first
    @participant  = @protocol.participants.first

    visit participant_path(@participant)
  end

  def and_i_add_a_procedure
    visit_group = @participant.appointments.first.visit_group
    service     = @protocol.organization.inclusive_descendant_services(:per_participant).first

    bootstrap_select('#appointment_select', visit_group.name)
    bootstrap_select('#service_list', service.name)
    fill_in 'service_quantity', with: '1'
    page.find('button.add_service').click
  end

  def then_i_should_see_the_procedure_in_the_appointment_calendar
    expect(page).to have_css('.procedures .procedure', count: 1)
  end

  def and_i_add_two_procedures
    visit_group = @participant.appointments.first.visit_group
    service     = @protocol.organization.inclusive_descendant_services(:per_participant).first

    bootstrap_select('#appointment_select', visit_group.name)
    bootstrap_select('#service_list', service.name)
    fill_in 'service_quantity', with: '2'
    page.find('button.add_service').click
  end

  def then_i_should_see_two_procedures_in_the_appointment_calendar
    expect(page).to have_css('.procedures .procedure', count: 2)
  end
end
