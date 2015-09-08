require 'rails_helper'

feature 'Identity views Procedures grouped by Service', js: true do

  before(:each) do
    @protocol    = create_and_assign_protocol_to_me
    @participant = Participant.first
    @appointment = Appointment.first
    @services    = @protocol.organization.inclusive_child_services(:per_participant)

    visit participant_path(@participant)
    bootstrap_select '#appointment_select', @appointment.name
    wait_for_ajax
  end

  scenario 'and sees that single Services are not grouped' do
    given_an_appointment_with_unique_procedures
    then_i_should_see_a_non_grouped_services_row
  end

  scenario 'and sees that duplicate Services are grouped' do
    given_an_appointment_with_duplicated_procedures
    then_i_should_see_a_grouped_services_row
  end

  scenario 'and sees that duplicate Services are not grouped after updating R/T' do
    given_an_appointment_with_duplicated_procedures
    and_i_update_a_grouped_procedure_rt_out_of_the_group
    then_i_should_not_see_grouped_service_row
  end

  scenario 'and sees that duplicate Services are grouped after updating R/T' do
    given_an_appointment_with_two_procedures_with_different_billing
    and_i_update_a_grouped_procedure_rt_into_the_group
    then_i_should_see_a_grouped_services_row
  end

  scenario 'and sees that groups are dismantled after deleting all but one Procedure' do
    given_an_appointment_with_duplicated_procedures
    and_i_delete_a_procedure_out_of_the_group
    then_i_should_not_see_grouped_service_row
  end

  scenario 'and sees that grouped services are completed when the Complete All button is clicked' do
    given_an_appointment_with_duplicated_procedures
    when_i_select_the_service_in_the_core_dropdown
    and_i_click_complete_all
    then_i_should_see_all_procedures_completed
  end

  scenario 'and sees that single services are completed when the Complete All button is clicked' do

  end

  def given_an_appointment_with_unique_procedures
    @services.each do |service|
      bootstrap_select '#service_list', service.name
      find('button.add_service').click
      wait_for_ajax
    end
  end

  def when_i_select_the_service_in_the_core_dropdown
    bootstrap_multiselect '#core_multiselect', [Procedure.first.service_name]
  end

  def and_i_click_complete_all
    find('button.complete_all').click
  end

  def then_i_should_see_all_procedures_completed
    expect(page).to have_css('label.status.complete.active', count: 2)
    expect(@participant.procedures.first.status).to eq("complete")
    expect(@participant.procedures.last.status).to eq("complete")
  end

  def given_an_appointment_with_duplicated_procedures
    2.times do
      find('button.add_service').click
      wait_for_ajax
    end
  end

  def given_an_appointment_with_two_procedures_with_different_billing
    service = @services.first

    bootstrap_select '#service_list', service.name
    find('button.add_service').click
    wait_for_ajax
    procedure = Procedure.first
    bootstrap_select "#quantity_type_#{procedure.id}", 'T'
    wait_for_ajax

    bootstrap_select '#service_list', service.name
    find('button.add_service').click
    wait_for_ajax
  end

  def when_i_select_an_appointment_with_single_services
    bootstrap_select '#appointment_select', @appointment.name
  end

  def and_i_update_a_grouped_procedure_rt_out_of_the_group
    procedure = Procedure.first
    bootstrap_select "#quantity_type_#{procedure.id}", 'T'
    wait_for_ajax
  end

  def and_i_update_a_grouped_procedure_rt_into_the_group
    procedure = Procedure.first
    bootstrap_select "#quantity_type_#{procedure.id}", 'R'
    wait_for_ajax
  end

  def and_i_delete_a_procedure_out_of_the_group
    first('button.delete').click
  end

  def then_i_should_see_a_grouped_services_row
    expect(page).to have_css('tr.procedure-group')
  end

  def then_i_should_not_see_grouped_service_row
    expect(page).to_not have_css('tr.procedure-group')
  end

  def then_i_should_see_a_non_grouped_services_row
    expect(page).to have_css('table.procedures > tbody > tr.procedure')
  end
end
