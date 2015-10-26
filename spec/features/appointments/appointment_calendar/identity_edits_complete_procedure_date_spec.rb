require 'rails_helper'

feature 'Identity edits complete Procedure date', js: true do

  scenario 'and sees the complete date update' do
    given_i_have_added_a_procedure_to_an_appointment
    when_i_begin_the_appointment
    when_i_complete_the_procedure
    when_i_edit_the_completed_date
    then_i_should_see_the_completed_date_has_been_updated
  end

  def given_i_have_added_a_procedure_to_an_appointment
    protocol    = create_and_assign_protocol_to_me
    participant = protocol.participants.first
    visit_group = participant.appointments.first.visit_group
    service     = protocol.organization.inclusive_child_services(:per_participant).first

    visit participant_path participant
    bootstrap_select '#appointment_select', visit_group.name
    bootstrap_select '#service_list', service.name
    fill_in 'service_quantity', with: 1
    find('button.add_service').click
    wait_for_ajax
  end

  def when_i_begin_the_appointment
    find('button.start_visit').click
  end

  def when_i_complete_the_procedure
    find('label.status.complete').click
    wait_for_ajax
  end

  def when_i_edit_the_completed_date
    page.execute_script %Q{ $(".datetimepicker").siblings(".input-group-addon").trigger("click")}
    page.execute_script %Q{ $("td.day:contains('15')").trigger("click") }
    wait_for_ajax
  end

  def then_i_should_see_the_completed_date_has_been_updated
    expected_date = page.evaluate_script %Q{ $('table.procedures tbody input.datetimepicker').val(); }

    expect(expected_date).to match(%r{\d\d-15-\d\d\d\d})
  end
end

