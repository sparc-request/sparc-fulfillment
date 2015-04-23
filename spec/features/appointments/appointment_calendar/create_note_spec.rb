require 'rails_helper'

feature 'Create Note', js: true do

  scenario 'User creates a Note and views the Notes list' do
    as_a_user_who_has_added_a_procedure_to_the_appointment_calendar
    when_i_add_a_note_to_a_procedure
    and_i_view_the_notes_list
    then_i_shoud_see_the_note
  end

  def as_a_user_who_has_added_a_procedure_to_the_appointment_calendar
    protocol    = create(:protocol_imported_from_sparc)
    participant = protocol.participants.first
    visit_group = participant.appointments.first.visit_group
    service     = Service.first

    visit participant_path participant
    bootstrap_select '#appointment_select', visit_group.name
    find("#service_list > option[value='#{service.id}']").select_option
    fill_in 'service_quantity', with: '1'
    find('button.add_service').click
  end

  def when_i_add_a_note_to_a_procedure
    find('.procedure td.notes button.note.new').click
    fill_in 'note_comment', with: 'Test comment'
    click_button 'Save'
  end

  def and_i_view_the_notes_list
    find('.procedure td.notes button.notes.list').click
  end

  def then_i_shoud_see_the_note
    expect(page).to have_css('.modal-body .note .comment', text: 'Test comment')
  end
end
