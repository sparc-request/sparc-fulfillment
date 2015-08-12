require 'rails_helper'

feature 'Identity incompletes Procedure', js: true do

  scenario 'and sees completed and incompleted Notes' do
    given_i_have_completed_an_appointment
    when_i_incomplete_the_procedure
    when_i_view_the_notes_list
    then_i_should_see_two_complete_notes
  end

  def given_i_have_completed_an_appointment
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
    find('button.start_visit').click
    find('label.status.complete').click
    wait_for_ajax
  end

  def when_i_incomplete_the_procedure
    find('label.status.incomplete').click
    wait_for_ajax
    bootstrap_select '.reason-select', "Assessment missed"
    click_button 'Save'
    wait_for_ajax
  end

  def when_i_view_the_notes_list
    find('.procedure td.notes button.notes.list').click
  end

  def then_i_should_see_two_complete_notes
    expect(page).to have_css('.modal-body .detail .comment', text: 'Status set to ', count: 2)
  end
end
