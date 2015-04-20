require 'rails_helper'

feature 'Complete Procedure', js: true do

  scenario 'User marks a Procedure as complete once' do
    as_a_user_who_has_added_a_procedure_to_an_appointment
    when_i_complete_the_procedure
    and_i_view_the_notes_list
    then_i_should_see_complete_notes
  end

  scenario 'User marks a Procedure as complete, then incomplete, then complete again' do
    as_a_user_who_has_added_a_procedure_to_an_appointment
    when_i_complete_the_procedure
    then_i_incomplete_the_procedure 
    and_i_complete_the_procedure_again
    and_i_view_the_notes_list
    then_i_should_see_complete_notes 2
  end

  scenario 'User marks a Procedure as complete and then changes their mind, clicking complete again' do
    as_a_user_who_has_added_a_procedure_to_an_appointment
    when_i_complete_the_procedure
    and_i_view_the_notes_list
    then_i_should_see_complete_notes
    then_i_close_the_notes_list
    and_i_complete_the_procedure_again
    and_i_view_the_notes_list
    then_i_should_see_reset_notes
  end

  scenario 'User marks an incomplete Procedure as complete' do
    as_a_user_who_is_viewing_a_procedure_marked_as_incomplete
    when_i_complete_the_procedure
    and_i_view_the_notes_list
    then_i_should_see_complete_notes
  end

  def as_a_user_who_has_added_a_procedure_to_an_appointment
    protocol    = create(:protocol_imported_from_sparc)
    participant = protocol.participants.first
    visit_group = participant.appointments.first.visit_group
    service     = Service.first

    visit participant_path participant
    bootstrap_select '#appointment_select', visit_group.name
    find("#service_list > option[value='#{service.id}']").select_option
    fill_in 'service_quantity', with: 1
    find('button.add_service').click
  end

  def as_a_user_who_is_viewing_a_procedure_marked_as_incomplete
    as_a_user_who_has_added_a_procedure_to_an_appointment
    find('label.status.incomplete').click
    click_button "Save"
  end
  
  def then_i_close_the_notes_list
    first(".modal button.close").click
  end

  def when_i_complete_the_procedure
    find('label.status.complete').click
    wait_for_ajax
  end

  def and_i_view_the_notes_list
    find('button.notes.list').click
  end

  def then_i_should_see_complete_notes count=1
    expect(page).to have_css('.modal-body .note .comment', text: 'Status set to complete', count: count)
  end
  
  def then_i_should_see_reset_notes
    expect(page).to have_css('.modal-body .note .comment', text: 'Status reset', count: 1)
  end
  
  def then_i_incomplete_the_procedure
    find('label.status.incomplete').click
    click_button "Save"
    wait_for_ajax
  end

  alias :and_i_complete_the_procedure_again :when_i_complete_the_procedure
end
