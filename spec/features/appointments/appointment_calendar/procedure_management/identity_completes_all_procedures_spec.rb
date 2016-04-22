require 'rails_helper'

feature 'Identity completes all Procedures', js: true do

  scenario 'and sees the complete buttons are active' do
    given_i_have_added_n_procedures_to_an_appointment_such_that_n_is 2
    when_i_complete_all_the_procedures
    then_i_should_see_a_complete_all_modal
    when_i_save_the_modal
    and_i_unroll_the_procedures_accordion
    then_all_the_procedure_complete_buttons_should_be_active
  end

  scenario 'and sees the procedures are completed' do
    given_i_have_added_n_procedures_to_an_appointment_such_that_n_is 2
    when_i_complete_all_the_procedures
    then_i_should_see_a_complete_all_modal
    when_i_save_the_modal
    then_all_procedures_should_be_completed
  end

  scenario 'leaves defaults and sees the procedures are completed and updated with defaults' do
    given_i_have_added_n_procedures_to_an_appointment_such_that_n_is 2
    when_i_complete_all_the_procedures
    then_i_should_see_a_complete_all_modal
    with_a_default_completed_date_of_current_date
    and_with_a_default_performed_by_name_of_current_user
    when_i_save_the_modal
    then_all_procedures_should_be_completed
    and_all_procedures_should_have_completed_date_set_to_default
    and_all_procedures_should_have_performed_by_set_to_default
  end

  scenario 'edits defaults and sees the procedures are completed with updated data' do
    given_i_have_added_n_procedures_to_an_appointment_such_that_n_is 2
    when_i_complete_all_the_procedures
    then_i_should_see_a_complete_all_modal
    when_i_edit_the_default_date
    and_when_i_edit_the_default_performer
    when_i_save_the_modal
    then_all_procedures_should_be_completed
    and_all_procedures_should_have_selected_completed_date
    and_all_procedures_should_have_selected_performer
  end

  def given_i_have_added_n_procedures_to_an_appointment_such_that_n_is number_of_procedures
    @current_user         = create(:identity)
    @clinical_provider    = create(:identity)
    sub_service_request   = create(:sub_service_request_with_organization)
    protocol              = create(:protocol_imported_from_sparc, sub_service_request: sub_service_request)
    organization_provider = create(:organization_provider, name: "Provider")
    organization_program  = create(:organization_program, name: "Program", parent: organization_provider)
    organization          = sub_service_request.organization
    organization.update_attributes(parent: organization_program, name: "Core")
    FactoryGirl.create(:clinical_provider, identity: @clinical_provider, organization: organization)
    FactoryGirl.create(:clinical_provider, identity: @current_user, organization: organization)
    FactoryGirl.create(:project_role_pi, identity: @current_user, protocol: protocol)

    
    @participant = protocol.participants.first
    visit_group  = @participant.appointments.first.visit_group
    service      = protocol.organization.inclusive_child_services(:per_participant).first

    visit participant_path @participant
    bootstrap_select '#appointment_select', visit_group.name
    bootstrap_select '#service_list', service.name
    fill_in 'service_quantity', with: number_of_procedures
    find('button.add_service').click
    wait_for_ajax
    find('button.start_visit').click
    wait_for_ajax
  end

  def when_i_complete_all_the_procedures
    bootstrap_multiselect('#core_multiselect')
    find('button.complete_all').click
    wait_for_ajax
  end

  def then_i_should_see_a_complete_all_modal
    expect(page).to have_text("Complete Multiple Services")
  end

  def with_a_default_completed_date_of_current_date
    expected_date = page.evaluate_script %Q{ $(".modal_completed_date_field").data("DateTimePicker").date(); }
    expect(expected_date["_i"]).to eq(Time.current.strftime('%m-%d-%Y'))
  end

  def and_with_a_default_performed_by_name_of_current_user
    expect(page).to have_css('.modal-performed-by .performed-by-dropdown', text: "#{@identity.full_name}")
  end

  def when_i_save_the_modal
    find('button.save').click
  end

  def and_i_unroll_the_procedures_accordion
    find("tr.procedure-group td[colspan='8'] button.btn").click
  end

  def then_all_the_procedure_complete_buttons_should_be_active
    expect(page).to have_css('label.status.complete.active', count: 2)
  end

  def then_all_procedures_should_be_completed
    wait_for_ajax
    expect(@participant.procedures.first.status).to eq("complete")
    expect(@participant.procedures.last.status).to eq("complete")
  end

  def and_all_procedures_should_have_completed_date_set_to_default
    expect(@participant.procedures.first.completed_date).to eq(Time.current.strftime('%m-%d-%Y'))
    expect(@participant.procedures.last.completed_date).to eq(Time.current.strftime('%m-%d-%Y'))
  end

  def and_all_procedures_should_have_performed_by_set_to_default
    expect(@participant.procedures.first.performed_by).to eq(@identity.id)
    expect(@participant.procedures.last.performed_by).to eq(@identity.id)
  end

  def when_i_edit_the_default_date
    page.execute_script %Q{ $(".datetimepicker").siblings(".input-group-addon").trigger("click")}
    page.execute_script %Q{ $("td.day:contains('15')").trigger("click") }
    wait_for_ajax
  end

  def and_when_i_edit_the_default_performer
    binding.pry
    bootstrap_select ".performed-by-dropdown", @performer.full_name
  end

  def and_all_procedures_should_have_selected_completed_date
    expect(@participant.procedures.first.completed_date).to eq(Time.current.strftime('%m-15-%Y'))
    expect(@participant.procedures.last.completed_date).to eq(Time.current.strftime('%m-15-%Y'))
  end

  def and_all_procedures_should_have_selected_performer
  end

end
