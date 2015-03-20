require 'rails_helper'

feature 'View Notes', js: true do

  scenario 'User views Notes list when no Notes are present' do
    given_i_am_viewing_a_procedure
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

  def given_i_have_marked_a_procedure_as_complete
    given_i_am_viewing_a_procedure
    find('label.status.complete').click
  end

  def given_i_have_marked_a_procedure_as_incomplete
    reason = Note::REASON_TYPES.first

    given_i_am_viewing_a_procedure
    find('label.status.incomplete').click
    select reason, from: 'note_reason'
    fill_in 'note_comment', with: 'Test comment'
    click_button 'Save'
  end

  def given_i_am_viewing_a_procedure
    protocol    = create(:protocol_imported_from_sparc)
    participant = protocol.participants.first
    visit_group = participant.appointments.first.visit_group
    service     = Service.first

    visit protocol_participant_path protocol, participant
    bootstrap_select '#appointment_select', visit_group.name
    find("#service_list > option[value='#{service.id}']").select_option
    fill_in 'service_quantity', with: 1
    find('button.add_service').click
  end

  def when_i_view_the_notes_list
    find('button.notes.list').click
  end

  def then_i_should_see_a_complete_note
    expect(page).to have_css('.modal-body .note .comment', text: 'Set to complete')
  end

  def then_i_should_see_an_incomplete_note
    expect(page).to have_css('.modal-body .note .comment', text: 'Set to incomplete')
  end

  def then_i_should_be_notified_that_there_are_no_notes
    expect(page).to have_css('.modal-body', text: 'This procedure has no notes.')
  end
end
