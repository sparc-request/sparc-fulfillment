require 'rails_helper'

feature 'Complete Procedure', js: true do

  scenario 'User marks a Procedure as complete once' do
    as_a_user_who_has_added_a_procedure_to_an_appointment
    when_i_complete_the_procedure
    and_i_view_the_notes_list
    then_i_shoud_see_one_complete_note
  end

  scenario 'User marks a Procedure as complete twice' do
    as_a_user_who_has_added_a_procedure_to_an_appointment
    when_i_complete_the_procedure
    and_i_complete_the_procedure_again
    and_i_view_the_notes_list
    then_i_shoud_see_one_complete_note
  end

  scenario 'User marks an incomplete Procedure as complete' do
    as_a_user_who_is_viewing_a_procedure_marked_as_incomplete
    when_i_complete_the_procedure
    and_i_view_the_notes_list
    then_i_shoud_see_one_complete_note
  end

  def as_a_user_who_has_added_a_procedure_to_an_appointment
    protocol    = create(:protocol_imported_from_sparc)
    participant = protocol.participants.first
    visit_group = participant.appointments.first.visit_group
    service     = Service.first

    visit protocol_participant_path protocol, participant
    bootstrap_select '#appointment_select', visit_group.name
    select service.name, from: 'service_list'
    fill_in 'service_quantity', with: 1
    find('button.add_service').click
  end

  def as_a_user_who_is_viewing_a_procedure_marked_as_incomplete
    as_a_user_who_has_added_a_procedure_to_an_appointment
    find('label.status.incomplete').click
  end

  def when_i_complete_the_procedure
    find('label.status.complete').click
  end

  def and_i_view_the_notes_list
    find('button.notes.list').click
  end

  def then_i_shoud_see_one_complete_note
    expect(page).to have_css('.modal-body .note .comment', text: 'Set to complete', count: 1)
  end

  alias :and_i_complete_the_procedure_again :when_i_complete_the_procedure
end
