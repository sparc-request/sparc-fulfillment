require 'rails_helper'

feature 'View Notes', js: true do

  scenario 'User views Notes list when no Notes are present' do
    given_i_am_viewing_a_procedure
    when_i_begin_an_appointment
    when_i_view_the_notes_list
    then_i_should_be_notified_that_there_are_no_notes
  end

  scenario 'User views Notes list after marking Procedure as complete' do
    given_i_have_marked_a_procedure_as_complete
    when_i_view_the_notes_list
    then_i_should_see_a_complete_note
  end

  scenario 'User views Notes list after marking Procedure as incomplete' do
    given_i_have_marked_a_procedure_as_incomplete
    when_i_view_the_notes_list
    then_i_should_see_an_incomplete_note
  end

  def given_i_am_viewing_a_procedure
    protocol    = create_and_assign_protocol_to_me
    participant = protocol.participants.first
    visit_group = participant.appointments.first.visit_group
    service     = protocol.organization.inclusive_child_services(:per_participant).first

    visit participant_path participant
    bootstrap_select '#appointment_select', visit_group.name
    bootstrap_select '#service_list', service.name
    fill_in 'service_quantity', with: 1
    find('button.add_service').click
  end

  def given_i_have_marked_a_procedure_as_complete
    given_i_am_viewing_a_procedure
    when_i_begin_an_appointment
    find('label.status.complete').click
  end

  def given_i_have_marked_a_procedure_as_incomplete
    reason = Procedure::NOTABLE_REASONS.first

    given_i_am_viewing_a_procedure
    when_i_begin_an_appointment
    find('label.status.incomplete').click
    bootstrap_select '.reason-select', reason
    fill_in 'procedure_notes_attributes_0_comment', with: 'Test comment'
    click_button 'Save'
  end

  def when_i_begin_an_appointment
    find('button.start_visit').click
  end

  def when_i_view_the_notes_list
    find('.procedure td.notes button.notes.list').click
  end

  def then_i_should_be_notified_that_there_are_no_notes
    expect(page).to have_css('.modal-body', text: 'This procedure has no notes.')
  end
  
  def then_i_should_see_a_complete_note
    expect(page).to have_css('.modal-body .detail .comment', text: 'Status set to complete')
  end

  def then_i_should_see_an_incomplete_note
    expect(page).to have_css('.modal-body .detail .comment', text: 'Status set to incomplete')
  end
end
