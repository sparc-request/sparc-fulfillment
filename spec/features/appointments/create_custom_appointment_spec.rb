require 'rails_helper'

feature 'Custom appointment', js: true do

  scenario 'User creates custom appointmet' do
    when_i_visit_a_participants_calendar
    as_a_user_who_clicks_create_custom_appointment
    when_i_click_save_appointment
    then_i_should_see_an_error_message
    then_i_fill_in_the_form
    when_i_click_save_appointment
    wait_for_ajax
    then_i_should_see_the_newly_created_appointment
    when_i_select_the_appointment
    then_add_a_procedure
    then_i_complete_it
    then_it_should_appear_on_the_dashboard
  end

  def when_i_visit_a_participants_calendar
    protocol    = create(:protocol_imported_from_sparc)
    participant = protocol.participants.first

    visit participant_path participant
  end

  def as_a_user_who_clicks_create_custom_appointment
    find('button.appointment.new').click
  end
  
  def when_i_click_save_appointment
    click_button 'Save'
  end

  def then_i_should_see_an_error_message
    expect(page).to have_content("Name can't be blank")
  end

  def then_i_fill_in_the_form
    fill_in 'custom_appointment_name', with: 'Test Visit'
  end

  def then_i_should_see_the_newly_created_appointment
    expect(page).to have_css("#appointment_select option", visible: false, text: "Test Visit")
  end

  def when_i_select_the_appointment
    @service = Service.per_participant_visits.first
    @service.update_attributes(name: 'Test Service')
    bootstrap_select '#appointment_select', "Test Visit"
    wait_for_ajax
  end

  def then_add_a_procedure
    bootstrap_select '#service_list', 'Test Service'
    fill_in 'service_quantity', with: 1
    find('button.add_service').click
    wait_for_ajax
  end

  def then_i_complete_it
    find('button.start_visit').click
    find('label.status.complete').click
    wait_for_ajax
    click_button 'Complete Visit'
  end

  def then_it_should_appear_on_the_dashboard
    expect(page).to have_content('Test Visit')
  end
end
