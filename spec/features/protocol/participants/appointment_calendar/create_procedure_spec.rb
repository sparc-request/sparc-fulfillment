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
    protocol      = create(:protocol_imported_from_sparc)
    @participant  = protocol.participants.first

    visit protocol_participant_path(protocol, @participant)
  end

  def and_i_add_a_procedure
    visit_group = @participant.appointments.first.visit_group
    service     = Service.first

    bootstrap_select('#appointment_select', visit_group.name)
    find("#service_list > option[value='#{service.id}']").select_option
    fill_in 'service_quantity', with: '1'
    page.find('button.add_service').trigger('click')
  end

  def then_i_should_see_the_procedure_in_the_appointment_calendar
    expect(page).to have_css('.procedures .procedure', count: 1)
  end

  def and_i_add_two_procedures
    visit_group = @participant.appointments.first.visit_group
    service     = Service.first

    bootstrap_select('#appointment_select', visit_group.name)
    find("#service_list > option[value='#{service.id}']").select_option
    fill_in 'service_quantity', with: '2'
    page.find('button.add_service').trigger('click')
  end

  def then_i_should_see_two_procedures_in_the_appointment_calendar
    expect(page).to have_css('.procedures .procedure', count: 2)
  end
end
