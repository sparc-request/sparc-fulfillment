require 'rails_helper'

feature 'Create Procedure Note', js: true do
  context 'appointment started' do
    scenario 'User creates a Note and views the Notes list' do
      as_a_user_who_has_added_a_procedure_to_the_appointment_calendar
      and_begins_appointment
      when_i_add_a_note_to_a_procedure
      and_i_view_the_notes_list
      then_i_shoud_see_the_note
    end
  end

  context 'appointment not started' do
    scenario 'User attempts to add procedure notes to a Procedure' do
      as_a_user_who_has_added_a_procedure_to_the_appointment_calendar
      when_i_try_to_add_a_procedure_note_i_should_see_a_helpful_message
    end
  end

  def as_a_user_who_has_added_a_procedure_to_the_appointment_calendar
    protocol    = create(:protocol_imported_from_sparc)
    participant = protocol.participants.first
    visit_group = participant.appointments.first.visit_group
    service     = Service.per_participant_visits.first

    visit participant_path participant
    bootstrap_select '#appointment_select', visit_group.name
    find("#service_list > option[value='#{service.id}']").select_option
    fill_in 'service_quantity', with: '1'
    find('button.add_service').click
  end

  def and_begins_appointment
    find('button.start_visit').click
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
    expect(page).to have_css('.modal-body .detail .comment', text: 'Test comment')
  end

  def when_i_try_to_add_a_procedure_note_i_should_see_a_helpful_message
    accept_alert(with: 'Please click Start Visit and enter a start date to continue.') do
      find('.procedure td.notes button.note.new').trigger('click')
    end
  end
end
