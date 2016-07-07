require 'rails_helper'

feature 'Start Complete Buttons', js: true do

  context 'User visits appointment with no start date or completed_date' do
    scenario 'and sees the start button is active and the complete button disabled' do
      given_i_am_viewing_an_appointment
      then_i_should_see_the_start_button
      then_i_should_see_the_complete_button_disabled
    end
  end

  context 'User visits appointment with start date but no completed date' do
    scenario 'and sees the start date picker and the completed button active' do
      given_i_am_viewing_an_appointment
      given_there_is_a_start_date
      when_i_load_the_page_and_select_a_visit
      then_i_should_see_the_start_datepicker
      then_i_should_see_the_complete_button
    end
  end

  context 'User visits appointment with start date and completed date' do
    scenario 'and sees the start date picker and the completed date picker' do
      given_i_am_viewing_an_appointment
      given_there_is_a_start_date_and_a_completed_date
      when_i_load_the_page
      then_i_should_see_the_start_datepicker
      then_i_should_see_the_completed_datepicker
    end
  end

  context 'User clicks start button' do
    scenario 'and sees the start datepicker and the completed button' do
      given_i_am_viewing_an_appointment
      when_i_click_the_start_button
      then_i_should_see_the_start_datepicker
      then_i_should_see_the_complete_button
    end
  end

  context 'User clicks complete button' do
    scenario 'and sees the start date picker and the completed datepicker' do
      given_i_am_viewing_an_appointment
      given_there_is_a_start_date
      when_i_load_the_page_and_select_a_visit
      when_i_click_the_complete_button
      then_i_should_see_the_start_datepicker
      then_i_should_see_the_completed_datepicker
    end
  end

  context 'User sets completed date and start date' do
    scenario 'and sees the completed and start date updated' do
      now = Time.current

      given_i_am_viewing_an_appointment
      given_there_is_a_start_date_and_a_completed_date
      when_i_load_the_page
      when_i_set_the_completed_date_to now
      when_i_set_the_start_date_to now
      then_i_should_see_the_completed_date_at now
      then_i_should_see_the_start_date_at now
    end
  end

  context 'User sets start date to future then clicks complete button' do
    scenario 'and sees the completed date updated' do
      future = Time.current + 1.day

      given_i_am_viewing_an_appointment
      given_there_is_a_start_date
      when_i_load_the_page_and_select_a_visit
      when_i_set_the_start_date_to future
      when_i_click_the_complete_button
      then_i_should_see_the_completed_date_at future
    end
  end

  def given_i_am_viewing_an_appointment
    @protocol    = create_and_assign_protocol_to_me
    @participant = @protocol.participants.first
    @appointment = @participant.appointments.first
    @visit_group = @appointment.visit_group

    visit participant_path(@participant)
    wait_for_ajax
    bootstrap_select '#appointment_select', @visit_group.name
    wait_for_ajax
  end

  def given_there_is_a_start_date
    @appointment.start_date = Time.current
    @appointment.save
    @appointment.reload
  end

  def given_there_is_a_completed_date
    @appointment.completed_date = Time.current
    @appointment.save
    @appointment.reload
  end

  def given_there_is_a_start_date_and_a_completed_date
    given_there_is_a_start_date
    given_there_is_a_completed_date
  end

  def when_i_load_the_page
    visit current_path
    wait_for_ajax
    
    find('#completed-appointments-table tr', text: @visit_group.name).click
    wait_for_ajax
  end

  def when_i_load_the_page_and_select_a_visit
    visit current_path
    wait_for_ajax
    
    bootstrap_select '#appointment_select', @visit_group.name
    wait_for_ajax
  end

  def when_i_click_the_start_button
    click_button 'Start Visit'
    wait_for_ajax
  end

  def when_i_click_the_complete_button
    click_button 'Complete Visit'
    wait_for_ajax
  end

  def when_i_set_the_start_date_to date
    find('input#start_date').click
    within '.bootstrap-datetimepicker-widget' do
      first("td.day:not(.old)", text: "#{date.day}").click
    end
    find(".control-label", text: "Start Date:").click
  end

  def when_i_set_the_completed_date_to date
    find('input#completed_date').click
    within '.bootstrap-datetimepicker-widget' do
      first("td.day:not(.old)", text: "#{date.day}").click
    end
    find(".control-label", text: "Completed Date:").click
  end

  def then_i_should_see_the_start_button
    expect(page).to have_css('button.btn-success.start_visit', visible: true)
  end

  def then_i_should_see_the_complete_button
    expect(page).to have_css('button.btn-danger.complete_visit', visible: true)
  end

  def then_i_should_see_the_complete_button_disabled
    expect(page).to have_css('button.btn-danger.complete_visit.disabled', visible: true)
  end

  def then_i_should_see_the_start_datepicker
    expect(page).to have_css('input#start_date', visible: true)
  end

  def then_i_should_see_the_completed_datepicker
    expect(page).to have_css('input#completed_date', visible: true)
  end

  def then_i_should_see_the_start_date_at date
    find('input#start_date').click
    expect(page).to have_css('td.day.active', text: "#{date.day}")
  end

  def then_i_should_see_the_completed_date_at date
    find('#completed_date')
    expected_date = page.evaluate_script %Q{ $('#completed_date').first().val(); }
    expect(expected_date.split().first).to eq(date.strftime('%m/%d/%Y'))
  end
end
