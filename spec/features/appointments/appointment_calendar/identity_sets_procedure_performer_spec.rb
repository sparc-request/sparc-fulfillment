require 'rails_helper'

feature 'Identity sets Procedure performer', js: true do

  scenario 'without selecting a Performer from the Performer dropdown' do
    given_i_have_added_a_procedure_to_an_appointment
    when_i_complete_the_procedure
    then_i_should_see_that_i_am_the_procedure_performer
  end

  scenario 'and then un-completes the Procedure' do
    given_i_have_completed_a_procedure
    when_i_incomplete_the_procedure
    then_i_should_see_that_the_performer_has_not_been_set
  end

  def given_i_have_added_a_procedure_to_an_appointment
    protocol    = create_and_assign_protocol_to_me
    participant = protocol.participants.first
    visit_group = participant.appointments.first.visit_group
    service     = protocol.organization.inclusive_child_services(:per_participant).first

    visit participant_path participant
    bootstrap_select '#appointment_select', visit_group.name
    bootstrap_select '#service_list', service.name
    fill_in 'service_quantity', with: 1
    find('button.add_service').click
    wait_for_ajax
  end

  def given_i_have_completed_a_procedure
    given_i_have_added_a_procedure_to_an_appointment
    when_i_complete_the_procedure
  end

  def when_i_complete_the_procedure
    find('button.start_visit').click
    wait_for_ajax
    find('label.status.complete').click
    wait_for_ajax
  end

  def when_i_incomplete_the_procedure
    find('label.status.complete').click
    wait_for_ajax
  end

  def then_i_should_see_that_i_am_the_procedure_performer
    @procedure  = Procedure.first
    @identity   = Identity.first

    expect(page).to have_css("tr.procedure[data-id='#{@procedure.id}'] .bootstrap-select.performed-by-dropdown span.filter-option", text: @identity.full_name)
  end

  def then_i_should_see_that_the_performer_has_not_been_set
    @procedure = Procedure.first

    expect(page).to have_css("tr.procedure[data-id='#{@procedure.id}'] .bootstrap-select.performed-by-dropdown span.filter-option", text: 'Nothing selected')
  end
end
