require 'rails_helper'

feature 'Identity views Procedures grouped by Service', js: true do

  before(:each) do
    @protocol    = create_and_assign_protocol_to_me
    @participant = Participant.first
    @appointment = Appointment.first
    @services    = @protocol.organization.inclusive_child_services(:per_participant)
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
    given_an_appointment_with_unique_procedures
    and_i_update_a_grouped_procedure_rt_into_the_group
    then_i_should_see_a_grouped_services_row
  end

  def given_an_appointment_with_unique_procedures
    visit participant_path(@participant)
    bootstrap_select '#appointment_select', @appointment.name
    wait_for_ajax

    @services.each do |service|
      bootstrap_select '#service_list', service.name
      find('button.add_service').click
      wait_for_ajax
    end
  end

  def given_an_appointment_with_duplicated_procedures
    visit participant_path(@participant)
    bootstrap_select '#appointment_select', @appointment.name
    wait_for_ajax

    3.times do
      find('button.add_service').click
      wait_for_ajax
    end
  end

  def when_i_select_an_appointment_with_single_services
    bootstrap_select '#appointment_select', @appointment.name
  end

  def when_i_update_a_grouped_procedures_rt

  end

  def and_i_update_a_grouped_procedure_rt_out_of_the_group
    procedure = Procedure.first
    bootstrap_select "#quantity_type_#{procedure.id}", 'T'
    wait_for_ajax
  end

  def and_i_update_a_grouped_procedure_rt_into_the_group
  end

  def then_i_should_see_a_grouped_services_row
    expect(page).to have_css('table.procedures tbody tr.grouped_services_row table.accordian')
  end

  def then_i_should_see_a_non_grouped_services_row
    expect(page).to_not have_css('table.procedures tbody > tr.procedure')
  end
end
