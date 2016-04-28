require 'rails_helper'

feature 'Identity incompletes all Procedures', js: true do

  before :each do
    @current_identity     = Identity.first
    @other_identity       = create(:identity, first_name: 'Juan', last_name: 'Leonardo')
    sub_service_request   = create(:sub_service_request_with_organization)
    protocol              = create(:protocol_imported_from_sparc, sub_service_request: sub_service_request)
    organization_provider = create(:organization_provider, name: "Provider")
    organization_program  = create(:organization_program, name: "Program", parent: organization_provider)
    organization          = sub_service_request.organization

    organization.update_attributes(parent: organization_program, name: "Core")

    FactoryGirl.create(:clinical_provider, identity: @current_identity, organization: organization)
    FactoryGirl.create(:project_role_pi, identity: @current_identity, protocol: protocol)

    FactoryGirl.create(:clinical_provider, identity: @other_identity, organization: organization)
    FactoryGirl.create(:project_role_pi, identity: @other_identity, protocol: protocol)
    
    @participant = protocol.participants.first
    visit_group  = @participant.appointments.first.visit_group
    service      = protocol.organization.inclusive_child_services(:per_participant).first

    visit participant_path @participant

    bootstrap_select '#appointment_select', visit_group.name
    bootstrap_select '#service_list', service.name
  end

  context 'and gives a valid reason' do
    scenario 'and sees the incomplete procedures' do
      given_i_have_added_n_procedures_to_an_appointment_such_that_n_is 2
      when_i_click_the_incomplete_all_button
      when_i_give_a_valid_reason_and_save
      then_all_the_procedure_incomplete_buttons_should_be_active
      then_all_procedures_should_be_incomplete
    end
  end

  context 'and gives an invalid reason' do
    scenario 'and sees an error message' do
      given_i_have_added_n_procedures_to_an_appointment_such_that_n_is 2
      when_i_click_the_incomplete_all_button
      when_i_give_an_invalid_reason
      then_i_should_see_an_error_message
    end
  end

  context 'and leaves modal defaults' do
    scenario 'sees the procedures are incompleted' do
      given_i_have_added_n_procedures_to_an_appointment_such_that_n_is 2
      when_i_click_the_incomplete_all_button
      then_i_should_see_a_incomplete_all_modal
      and_with_a_default_performed_by_name_of_current_user
      when_i_give_a_valid_reason_and_save
      and_i_unroll_the_procedures_accordion
      and_all_procedures_should_have_performed_by_set_to_default
    end
  end
  
  context 'and edits modal defaults' do
    scenario 'sees the procedures are incompleted' do
      given_i_have_added_n_procedures_to_an_appointment_such_that_n_is 2
      when_i_click_the_incomplete_all_button
      then_i_should_see_a_incomplete_all_modal
      and_when_i_edit_the_default_performer
      when_i_give_a_valid_reason_and_save
      and_i_unroll_the_procedures_accordion
      and_all_procedures_should_have_selected_performer
    end
  end

  def given_i_have_added_n_procedures_to_an_appointment_such_that_n_is(qty=1)
    fill_in 'service_quantity', with: qty
    find('button.add_service').click
    wait_for_ajax
    find('button.start_visit').click
    wait_for_ajax
  end

  def when_i_click_the_incomplete_all_button
    bootstrap_multiselect '#core_multiselect'
    find('button.incomplete_all').click
    wait_for_ajax
  end

  def when_i_give_a_valid_reason_and_save
    bootstrap_select '#reason.reason-select', "Assessment missed"
    find('button.save').click
    wait_for_ajax
  end

  def when_i_give_an_invalid_reason
    find('button.save').click
    wait_for_ajax
  end

  def then_all_the_procedure_incomplete_buttons_should_be_active
    expect(page).to have_css('label.status.incomplete.active', count: 2, visible: false)
  end

  def then_all_procedures_should_be_incomplete
    expect(@participant.procedures.first.status).to eq("incomplete")
    expect(@participant.procedures.last.status).to eq("incomplete")
  end

  def then_i_should_see_an_error_message
    expect(page).to have_css('.alert.alert-danger')
    expect(page).to have_content("Please complete the required fields:")
  end

  def then_i_should_see_a_incomplete_all_modal
    expect(page).to have_text("Incomplete Multiple Services")
  end

  def and_with_a_default_performed_by_name_of_current_user
    expect(page).to have_css('.modal-performed-by .performed-by-dropdown', text: "#{@current_identity.full_name}")
  end

  def when_i_save_the_modal
    find('button.save').click
  end

  def and_i_unroll_the_procedures_accordion
    find("tr.procedure-group td[colspan='8'] button.btn").click
  end

  def and_all_procedures_should_have_performed_by_set_to_default
    find("tr.procedure[data-id='1'] td.performed-by .selectpicker")
    find("tr.procedure[data-id='2'] td.performed-by .selectpicker")

    procedure1_performed_by = page.evaluate_script %Q{ $("tr.procedure[data-id='1'] td.performed-by .selectpicker").val(); }
    procedure2_performed_by = page.evaluate_script %Q{ $("tr.procedure[data-id='2'] td.performed-by .selectpicker").val(); }

    expect(procedure1_performed_by.to_i).to eq(@current_identity.id)
    expect(procedure2_performed_by.to_i).to eq(@current_identity.id)
  end

  def and_when_i_edit_the_default_performer
    bootstrap_select ".performed-by-dropdown", @other_identity.full_name
  end

  def and_all_procedures_should_have_selected_performer
    find("tr.procedure[data-id='1'] td.performed-by .selectpicker")
    find("tr.procedure[data-id='2'] td.performed-by .selectpicker")

    procedure1_performed_by = page.evaluate_script %Q{ $("tr.procedure[data-id='1'] td.performed-by .selectpicker").val(); }
    procedure2_performed_by = page.evaluate_script %Q{ $("tr.procedure[data-id='2'] td.performed-by .selectpicker").val(); }

    expect(procedure1_performed_by.to_i).to eq(@other_identity.id)
    expect(procedure2_performed_by.to_i).to eq(@other_identity.id)
  end
end
