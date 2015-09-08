require 'rails_helper'

feature 'Identity resets appointment', js: true do
  scenario 'the appointment is completed, but is then reset' do
    given_i_am_viewing_a_participants_calendar_with_procedures
    and_i_start_the_appointment
    and_i_add_an_unscheduled_procedure
    and_i_resolve_all_procedures
    and_i_complete_the_visit
    and_i_click_the_reset_button
    i_should_see_a_reset_appointment
  end

  def given_i_am_viewing_a_participants_calendar_with_procedures
    @protocol     = create_and_assign_blank_protocol_to_me
    project_role  = create(:project_role_pi, protocol: @protocol)
    arm           = create(:arm_imported_from_sparc, protocol: @protocol, visit_count: 10)
    @participant  = Participant.first
    @visit_group  = arm.visit_groups.first
    @appointment  = @visit_group.appointments.where(participant_id: @participant).first
    line_item_1   = arm.line_items[0]
    line_item_2   = arm.line_items[1]

    visit protocol_path(@protocol.id)
    find("#line_item_#{line_item_1.id} .check_row").click()
    wait_for_ajax
    find("#line_item_#{line_item_2.id} .check_row").click()
    wait_for_ajax

    visit participant_path(@participant)
    bootstrap_select('#appointment_select', @visit_group.name)
    wait_for_ajax
  end

  def and_i_start_the_appointment
    find('button.start_visit').click
    wait_for_ajax
  end

  def and_i_add_an_unscheduled_procedure
    service     = @protocol.organization.inclusive_child_services(:per_participant).first

    bootstrap_select('#service_list', service.name)
    fill_in 'service_quantity', with: '1'
    page.find('button.add_service').click
    wait_for_ajax
  end

  def and_i_resolve_all_procedures
    procedures = @appointment.procedures

    find("tr[data-id='#{procedures[0].id}'] label.status.complete").click
    wait_for_ajax
    find("tr[data-id='#{procedures[1].id}'] label.status.incomplete").click
    wait_for_ajax
    bootstrap_select '.reason-select', "Assessment missed"
    click_button 'Save'
    wait_for_ajax

    find("tr[data-id='#{procedures[2].id}'] button.followup.new").click
    bootstrap_select '#task_assignee_id', Identity.first.full_name
    page.execute_script %Q{ $("#follow_up_procedure_datepicker").children(".input-group-addon").trigger("click")}
    page.execute_script %Q{ $("td.day:contains('10')").trigger("click") }
    fill_in 'Comment', with: 'Test comment'
    click_button 'Save'
    wait_for_ajax
  end

  def and_i_complete_the_visit
    find("button.complete_visit").click
    wait_for_ajax
  end

  def and_i_click_the_reset_button
    accept_confirm do
      find("button.reset_visit").click
    end
    wait_for_ajax
  end

  def i_should_see_a_reset_appointment
    expect(page).to have_css('button.start_visit', visible: true)
    expect(page).to have_css('button.complete_visit.disabled', visible: true)
    expect(page). to have_css('td.status .pre_start_disabled', visible: true, count: 2)
  end
end
