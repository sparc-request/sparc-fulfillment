require 'rails_helper'

feature 'Create Procedure Note', js: true do
  
  context 'User creates a procedure note' do
    scenario 'and sees the note in the notes list' do
      given_i_have_added_a_procedure_to_the_appointment_calendar
      when_i_begin_an_appointment
      when_i_add_a_note_to_the_procedure
      when_i_view_the_notes_list
      then_i_shoud_see_the_note
    end
  end

  def given_i_have_added_a_procedure_to_the_appointment_calendar
    protocol    = create_and_assign_protocol_to_me
    participant = protocol.participants.first
    visit_group = participant.appointments.first.visit_group
    service     = protocol.organization.inclusive_child_services(:per_participant).first

    visit participant_path participant
    bootstrap_select '#appointment_select', visit_group.name
    bootstrap_select '#service_list', service.name
    fill_in 'service_quantity', with: '1'
    find('button.add_service').click
  end

  def when_i_begin_an_appointment
    find('button.start_visit').click
  end

  def when_i_add_a_note_to_the_procedure
    find('.procedure td.notes button.notes.list').click
    find('button.note.new').click
    fill_in 'note_comment', with: 'Test comment'
    click_button 'Save'
  end

  def when_i_view_the_notes_list
    find('.procedure td.notes button.notes.list').click
  end

  def then_i_shoud_see_the_note
    expect(page).to have_css('.modal-body .detail .comment', text: 'Test comment')
  end
end
