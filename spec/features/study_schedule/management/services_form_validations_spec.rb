require 'rails_helper'

feature 'Services form validations', js: true do

  context 'creating line items validates' do

    scenario 'the presence of the arms' do
      given_i_have_a_protocol_and_am_looking_at_the_study_schedule
      when_i_click_the_add_services_button
      and_submit_the_form
      then_i_should_see_the_error "Arms to add '#{@services.first.name}' to must be selected"
    end
  end

  context 'removing line items validates' do

    scenario 'the presence of the arms' do
      given_i_have_a_protocol_and_am_looking_at_the_study_schedule
      when_i_click_the_remove_services_button
      and_select_the_service
      and_submit_the_form
      then_i_should_see_the_error "Arms to remove '#{@service.name}' from must be selected"
    end

    scenario 'none of the line items have completed procedures' do
      given_i_have_a_protocol_and_am_looking_at_the_study_schedule
      when_there_is_a_completed_procedure
      when_i_click_the_remove_services_button
      and_select_the_service
      and_select_the_arm
      and_submit_the_form
      then_i_should_see_the_error "Service '#{@service.name}' on Arm '#{@arm.name}' has completed procedures and cannot be deleted"
    end
  end

  def given_i_have_a_protocol_and_am_looking_at_the_study_schedule
    @protocol = create_and_assign_protocol_to_me
    @services = @protocol.organization.inclusive_child_services(:per_participant)
    @arm      = @protocol.arms.first
    @service  = @arm.line_items.first.service
    visit protocol_path @protocol
  end

  def when_there_is_a_completed_procedure
    participant  = create(:participant_with_appointments, protocol: @protocol, arm: @arm)
    procedure    = create(:procedure_complete, service: @service, appointment: participant.appointments.first, arm: @arm, completed_date: "10-09-2010")
  end

  def when_i_click_the_add_services_button
    find("#add_service_button").click
  end

  def when_i_click_the_remove_services_button
    find("#remove_service_button").click
  end

  def and_select_the_service
    bootstrap_select "#remove_service_id", "#{@service.name}"
    wait_for_ajax
  end

  def and_select_the_arm
    bootstrap_select "#remove_service_arm_ids_", "#{@arm.name}"
    find("h4#line_item").click # click out of bootstrap multiple select
  end

  def and_submit_the_form
    find("input[type='submit']").click
    wait_for_ajax
  end

  def then_i_should_see_the_error message
    expect(page).to have_content message
  end
end
