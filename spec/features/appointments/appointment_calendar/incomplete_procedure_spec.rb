require 'rails_helper'

feature 'Incomplete Procedure', js: true do

  context 'appointment started' do

    scenario 'User marks a Procedure as incomplete once' do
      as_a_user_who_has_added_a_procedure_to_an_appointment
      and_begins_appointment
      when_i_incomplete_the_procedure
      and_i_view_the_notes_list
      then_i_should_see_one_incomplete_note
    end

    scenario 'User marks a Procedure as incomplete, then complete, then incomplete again' do
      as_a_user_who_has_added_a_procedure_to_an_appointment
      and_begins_appointment
      when_i_incomplete_the_procedure
      then_i_complete_the_procedure
      and_i_incomplete_the_procedure_again
      and_i_view_the_notes_list
      then_i_should_see_two_incomplete_notes
    end

    scenario 'User marks a complete Procedure as incomplete and supplies a Note' do
      as_a_user_who_is_viewing_a_procedure_marked_as_complete
      when_i_incomplete_the_procedure
      and_i_view_the_notes_list
      then_i_should_see_one_complete_note_and_one_incomplete_note
    end

    scenario 'User marks a complete Procedure as incomplete and then cancels' do
      as_a_user_who_has_added_a_procedure_to_an_appointment
      and_begins_appointment
      when_i_click_the_incommplete_button
      and_i_cancel_the_incomplete
      then_i_should_see_that_the_procedure_status_has_not_changed
    end

    scenario 'User marks a Procedure as incomplete and then changes their mind, clicking incomplete again' do
      as_a_user_who_has_added_a_procedure_to_an_appointment
      and_begins_appointment
      when_i_incomplete_the_procedure
      and_i_view_the_notes_list
      then_i_should_see_one_incomplete_note
      then_i_close_the_notes_list
      when_i_click_the_incommplete_button_again
      and_i_view_the_notes_list
      then_i_should_see_one_status_reset_note
      then_i_close_the_notes_list
      then_i_should_see_that_the_procedure_status_has_been_reset
    end
  end

  context 'appointment not started' do

    scenario 'User attempts to mark a Procedure as incomplete' do
      as_a_user_who_has_added_a_procedure_to_an_appointment
      when_i_try_to_incomplete_the_procedure_i_should_see_a_helpful_message
    end
  end

  def as_a_user_who_has_added_a_procedure_to_an_appointment
    protocol    = create(:protocol_imported_from_sparc)
    participant = protocol.participants.first
    visit_group = participant.appointments.first.visit_group
    service     = Service.per_participant_visits.first

    visit participant_path participant
    bootstrap_select '#appointment_select', visit_group.name
    find("#service_list > option[value='#{service.id}']").select_option
    fill_in 'service_quantity', with: 1
    find('button.add_service').click
  end

  def as_a_user_who_is_viewing_a_procedure_marked_as_complete
    as_a_user_who_has_added_a_procedure_to_an_appointment
    and_begins_appointment
    find('label.status.complete').click
  end

  def and_begins_appointment
    find('button.start_visit').click
  end

  def when_i_click_the_incommplete_button
    find('label.status.incomplete').click
    wait_for_ajax
  end
  
  def then_i_complete_the_procedure
    find('label.status.complete').click
    wait_for_ajax
  end

  def and_i_cancel_the_incomplete
    first(".modal button.close").click
  end

  def when_i_incomplete_the_procedure
    reason = Procedure::NOTABLE_REASONS.first

    when_i_click_the_incommplete_button
    select reason, from: 'procedure_notes_attributes_0_reason'
    fill_in 'procedure_notes_attributes_0_comment', with: 'Test comment'
    click_button 'Save'
  end

  def and_i_view_the_notes_list
    find('.procedure td.notes button.notes.list').click
  end

  def then_i_should_see_that_the_procedure_status_has_not_changed
    expect(page).to have_css("tr.procedure .date input[disabled]")
  end

  def then_i_should_see_one_incomplete_note
    expect(page).to have_css('.modal-body .polymorphic .comment', text: 'Status set to incomplete', count: 1)
  end
  
  def then_i_should_see_one_status_reset_note
    expect(page).to have_css('.modal-body .polymorphic .comment', text: 'Status reset', count: 1)
  end

  def then_i_should_see_one_complete_note
    expect(page).to have_css('.modal-body .polymorphic .comment', text: 'Status set to complete', count: 1)
  end

  def then_i_should_see_two_incomplete_notes
    expect(page).to have_css('.modal-body .polymorphic .comment', text: 'Status set to incomplete', count: 2)
  end

  def then_i_should_see_one_complete_note_and_one_incomplete_note
    then_i_should_see_one_complete_note
    then_i_should_see_one_incomplete_note
  end

  def when_i_try_to_incomplete_the_procedure_i_should_see_a_helpful_message
    accept_alert(with: 'Please click Start Visit and enter a start date to continue.') do
      find('label.status.incomplete').trigger('click')
      wait_for_ajax
    end
  end

  alias :and_i_incomplete_the_procedure_again :when_i_incomplete_the_procedure
  alias :when_i_click_the_incommplete_button_again :when_i_click_the_incommplete_button
  alias :then_i_should_see_that_the_procedure_status_has_been_reset :then_i_should_see_that_the_procedure_status_has_not_changed
  alias :then_i_close_the_notes_list :and_i_cancel_the_incomplete
end
