require 'rails_helper'

feature 'View appointment notes', js: true do

  context 'User views Notes list when no Notes are present' do
    scenario 'and sees a notification that there are no notes' do
      given_i_am_viewing_an_appointment
      when_i_view_the_notes_list
      then_i_should_be_notified_that_there_are_no_notes
    end
  end
  
  context 'User views Notes list when Notes are present' do
    scenario 'and sees a notification that there are notes' do
      given_i_am_viewing_an_appointment
      when_i_create_a_note
      when_i_view_the_notes_list
      then_i_should_be_notified_that_there_are_notes
    end
  end

  def given_i_am_viewing_an_appointment
    protocol      = create_and_assign_protocol_to_me
    @participant  = protocol.participants.first
    @visit_group  = @participant.appointments.first.visit_group
    @identity     = create(:identity)

    visit participant_path @participant

    bootstrap_select '#appointment_select', @visit_group.name
    wait_for_ajax
  end

  def when_i_view_the_notes_list
    find('h3.appointment_header button.notes.list').click
  end
  
  def when_i_create_a_note
    @participant.appointments.first.notes.create :comment => "A note", :identity => @identity
  end

  def then_i_should_be_notified_that_there_are_no_notes
    expect(page).to have_css('.modal-body', text: 'This appointment has no notes.')
  end
  
  def then_i_should_be_notified_that_there_are_notes
    expect(page).to have_css('.modal-body', text: 'A note')
  end
end
