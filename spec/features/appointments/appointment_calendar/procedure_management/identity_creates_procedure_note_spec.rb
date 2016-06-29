require 'rails_helper'

feature 'User creates a procedure note', js: true do

  context 'and views the Notes list before create' do
    scenario 'and sees a notification that there are no notes' do
      given_i_have_added_a_procedure_to_the_appointment_calendar
      when_i_begin_an_appointment
      when_i_view_the_notes_list
      then_i_should_see_a_notice_that_there_are_no_notes
    end
  end

  scenario 'and sees the note in the notes list' do
    given_i_have_added_a_procedure_to_the_appointment_calendar
    when_i_begin_an_appointment
    when_i_add_a_note_to_the_procedure
    when_i_view_the_notes_list
    then_i_should_see_the_note
  end

  def given_i_have_added_a_procedure_to_the_appointment_calendar
    protocol    = create_and_assign_protocol_to_me
    participant = protocol.participants.first
    visit_group = participant.appointments.first.visit_group
    service     = protocol.organization.inclusive_child_services(:per_participant).first

    visit participant_path participant
    wait_for_ajax

    bootstrap_select '#appointment_select', visit_group.name
    wait_for_ajax
    
    bootstrap_select '#service_list', service.name
    fill_in 'service_quantity', with: '1'
    find('button.add_service').click
    wait_for_ajax
  end

  def when_i_begin_an_appointment
    find('button.start_visit').click
    wait_for_ajax
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
  
  def then_i_should_see_a_notice_that_there_are_no_notes
    expect(page).to have_css('.modal-body', text: 'This procedure has no notes.')
  end

  def then_i_should_see_the_note
    expect(page).to have_css('.modal-body .detail .comment', text: 'Test comment')
  end
end
