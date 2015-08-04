require 'rails_helper'

feature 'User tries to view the participant calendar', js: true do

  before :each do
    given_i_am_viewing_the_participant_tracker
  end

  context 'and the participant is assigned to an arm' do
    scenario 'so the user sees the calendar icon is active' do
      given_a_participant_has_an_arm
      then_the_participant_calendar_icon_should_be_active
    end

    scenario 'so the user can access the participant calendar' do
      given_a_participant_has_an_arm
      when_i_click_the_participant_calendar_icon
      then_i_will_see_the_participant_calendar
    end
  end

  context 'and the participant is not assigned to an arm but has completed appointments/visits' do
    scenario 'so the user sees the calendar icon is active' do
      given_a_participant_does_not_have_an_arm
      given_a_participant_has_completed_appointments
      then_the_participant_calendar_icon_should_be_active
    end

    scenario 'so the user can access the participant calendar' do
      given_a_participant_does_not_have_an_arm
      given_a_participant_has_completed_appointments
      when_i_click_the_participant_calendar_icon
      then_i_will_see_the_participant_calendar
    end
  end

  context 'and the participant is not assigned to an arm and has no completed appointments/visits' do
    scenario 'so the user sees the calendar icon is inactive' do
      given_a_participant_does_not_have_an_arm
      given_a_participant_does_not_have_completed_appointments
      then_the_participant_calendar_icon_should_be_inactive
    end

    scenario 'so the user cant access the participant calendar' do
      given_a_participant_does_not_have_an_arm
      given_a_participant_does_not_have_completed_appointments
      when_i_click_the_participant_calendar_icon
      then_i_will_not_be_redirected
    end
  end

  def given_i_am_viewing_the_participant_tracker
    @protocol = create_and_assign_protocol_to_me
    @participant = @protocol.participants.first

    visit protocol_path @protocol
    click_link 'Participant Tracker'
  end

  def given_a_participant_has_an_arm
    @participant.arm = Arm.first
  end

  def given_a_participant_does_not_have_an_arm
    @participant.arm = nil
  end

  def given_a_participant_has_completed_appointments
    @appointment = @participant.appointments.first
    @visit_group = @appointment.visit_group

    visit participant_path @participant
    
    bootstrap_select '#appointment_select', @visit_group.name

    wait_for_ajax
    click_button 'Start Visit'
    wait_for_ajax
    click_button 'Complete Visit'
    wait_for_ajax
    
    visit protocol_path @protocol 
    click_link 'Participant Tracker'
    wait_for_ajax
  end

  def given_a_participant_does_not_have_completed_appointments
    @participant.appointments.completed.clear
  end

  def when_i_click_the_participant_calendar_icon
    find("tr[data-index='0'] td.calendar").click
  end

  def then_the_participant_calendar_icon_should_be_active
    expect(page).to have_css("tr[data-index='0'] td.calendar a.participant-calendar i.glyphicon")
  end

  def then_the_participant_calendar_icon_should_be_inactive
    expect(page).to have_css("tr[data-index='0'] td.calendar i.glyphicon")
  end
  
  def then_i_will_see_the_participant_calendar
    expect(current_path) == participants_path + '/' + @participant.id.to_s
  end

  def then_i_will_not_be_redirected
    expect(current_path) == protocols_path + '/' + @protocol.id.to_s + '#'
  end
end