require 'rails_helper'

feature 'Identity adds Procedure', js: true do

  scenario 'and sees it in the appointment calendar' do
    given_i_am_viewing_a_participants_calendar
    when_i_add_a_procedure
    then_i_should_see_the_procedure_in_the_appointment_calendar
  end

  scenario 'and sees that the Performed By selector does not have a selection' do
    given_i_am_viewing_a_participants_calendar
    when_i_add_a_procedure
    then_i_should_see_that_the_performed_by_selector_does_not_have_a_selection
  end

  def given_i_am_viewing_a_participants_calendar
    @protocol     = create_and_assign_protocol_to_me
    @participant  = @protocol.participants.first

    visit participant_path(@participant)
    wait_for_ajax
  end

  def when_i_add_a_procedure
    visit_group = @participant.appointments.first.visit_group
    service     = @protocol.organization.inclusive_child_services(:per_participant).first

    bootstrap_select('#appointment_select', visit_group.name)
    bootstrap_select('#service_list', service.name)
    fill_in 'service_quantity', with: '1'
    page.find('button.add_service').click
    wait_for_ajax
  end

  def then_i_should_see_the_procedure_in_the_appointment_calendar
    expect(page).to have_css('.procedures .procedure', count: 1)
  end

  def then_i_should_see_that_the_performed_by_selector_does_not_have_a_selection
    expected_value = page.evaluate_script %Q{ $('table.procedures .performed-by-dropdown').val(); }

    expect(expected_value).to eq('')
  end
end
