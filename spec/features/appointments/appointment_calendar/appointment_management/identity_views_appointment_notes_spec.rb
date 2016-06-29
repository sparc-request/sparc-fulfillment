require 'rails_helper'

feature 'User creates an appointment note', js: true do

  context 'and views the Notes List before create' do
    scenario 'and sees a notification that there are no notes' do
      given_i_am_viewing_an_appointment
      when_i_view_the_notes_list
      then_i_should_see_a_notice_that_there_are_no_notes
    end
  end
  
  scenario 'and sees a the notes' do
    given_i_am_viewing_an_appointment
    when_i_create_a_note
    when_i_view_the_notes_list
    then_i_should_see_the_note
  end

  def given_i_am_viewing_an_appointment
    protocol      = create_and_assign_protocol_to_me
    @participant  = protocol.participants.first
    @visit_group  = @participant.appointments.first.visit_group
    @identity     = create(:identity)

    visit participant_path @participant
    wait_for_ajax

    bootstrap_select '#appointment_select', @visit_group.name
    wait_for_ajax
  end

  def when_i_view_the_notes_list
    find('h3.appointment_header button.notes.list').click
  end
  
  def when_i_create_a_note
    when_i_view_the_notes_list
    wait_for_ajax
    click_button 'Add Note'
    wait_for_ajax
    fill_in 'note_comment', with: "I'm a note. Fear me."
    click_button 'Save'
    wait_for_ajax
  end

  def then_i_should_see_a_notice_that_there_are_no_notes
    expect(page).to have_css('.modal-body', text: 'This appointment has no notes.')
  end
  
  def then_i_should_see_the_note
    expect(page).to have_css('.modal-body', text: "I'm a note. Fear me.")
  end
end
