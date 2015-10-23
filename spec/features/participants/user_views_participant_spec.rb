require 'rails_helper'

feature 'User views Participant', js: true do

  scenario 'and does not have access' do
    given_i_do_not_have_access_to_a_protocol
    when_i_view_a_participants_calendar
    then_i_should_be_redirected_to_the_home_page
  end

  scenario 'and sees the Participants attributes in the header' do
    given_i_have_access_to_a_protocol
    when_i_view_a_participants_calendar
    then_i_should_see_the_participant_calendar
  end

  scenario 'and sees a list of Visits ordered by :completed_date' do
    given_i_have_access_to_a_protocol_with_appointments
    when_i_view_a_participants_calendar
    then_i_should_see_an_ordered_list_of_visits
  end

  def given_i_do_not_have_access_to_a_protocol
    @protocol    = create(:protocol_imported_from_sparc)
    @participant = @protocol.participants.first
  end

  def given_i_have_access_to_a_protocol
    @protocol     = create_and_assign_protocol_to_me
    @participant  = @protocol.participants.first
  end

  def given_i_have_access_to_a_protocol_with_appointments
    protocol      = create_and_assign_protocol_to_me
    @participant  = create(:participant_with_completed_appointments,
                            protocol: protocol,
                            arm: protocol.arms.first)
    @appointments = @participant.appointments
  end

  def when_i_view_a_participants_calendar
    visit participant_path @participant
    wait_for_ajax
  end

  def then_i_should_be_redirected_to_the_home_page
    expect(current_path).to eq root_path # gets redirected back to index
  end

  def then_i_should_see_the_participant_calendar
    expect(page).to have_css('#participant-info')
    expect(page).to have_content(@participant.full_name)
    expect(page).to have_content(@participant.mrn) unless @participant.mrn.blank?
    expect(page).to have_content(@participant.external_id) unless @participant.external_id.blank?
    expect(page).to have_content(@participant.arm.name) unless @participant.arm.blank?
    expect(page).to have_content(@participant.status)
    expect(page).to have_content(@protocol.id)
  end

  def then_i_should_see_an_ordered_list_of_visits
    @appointments.sort_by { |appointment| appointment.completed_date }.reverse.each_with_index do |appointment, index|
      expect(page).to have_css("table.visits tbody tr:nth-of-type(#{index + 1})", text: appointment.name)
    end
  end
end
