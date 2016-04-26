require 'rails_helper'

feature 'Identity incompletes all Procedures', js: true do

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

  scenario 'and sees the defaults for the incomplete modal' do
    given_i_have_added_n_procedures_to_an_appointment_such_that_n_is 2
    when_i_click_the_incomplete_all_button
    then_i_should_see_a_incomplete_all_modal
    with_a_default_incompleted_date_of_current_date
    and_with_a_default_performed_by_name_of_current_user
    when_i_give_a_valid_reason_and_save
    and_i_unroll_the_procedures_accordion
    and_all_procedures_should_have_incompleted_date_set_to_nil
    and_all_procedures_should_have_performed_by_set_to_default
  end

  scenario 'edits defaults and sees the procedures are completed with updated data' do
    given_i_have_added_n_procedures_to_an_appointment_such_that_n_is 2
    when_i_click_the_incomplete_all_button
    then_i_should_see_a_incomplete_all_modal
    when_i_edit_the_default_date
    and_when_i_edit_the_default_performer
    when_i_give_a_valid_reason_and_save
    and_i_unroll_the_procedures_accordion
    and_all_procedures_should_have_incompleted_date_set_to_nil
    and_all_procedures_should_have_selected_performer
  end

  def given_i_have_added_n_procedures_to_an_appointment_such_that_n_is(qty=1)
    @identity1              = Identity.first
    @identity2              = create(:identity, first_name: "Sassy")
    sub_service_request   = create(:sub_service_request_with_organization)
    protocol              = create(:protocol_imported_from_sparc, sub_service_request: sub_service_request)
    organization_provider = create(:organization_provider, name: "Provider")
    organization_program  = create(:organization_program, name: "Program", parent: organization_provider)
    organization          = sub_service_request.organization
    organization.update_attributes(parent: organization_program, name: "Core")

    FactoryGirl.create(:clinical_provider, identity: @identity1, organization: organization)
    FactoryGirl.create(:project_role_pi, identity: @identity1, protocol: protocol)
    FactoryGirl.create(:clinical_provider, identity: @identity2, organization: organization)
    FactoryGirl.create(:project_role_pi, identity: @identity2, protocol: protocol)
    
    @participant = protocol.participants.first
    visit_group  = @participant.appointments.first.visit_group
    service      = protocol.organization.inclusive_child_services(:per_participant).first

    visit participant_path @participant
    bootstrap_select '#appointment_select', visit_group.name
    wait_for_ajax
    bootstrap_select '#service_list', service.name
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

  def with_a_default_incompleted_date_of_current_date
    expected_date = page.evaluate_script %Q{ $(".modal_date_field").data("DateTimePicker").date(); }
    expect(expected_date["_i"]).to eq(Time.current.strftime('%m-%d-%Y'))
  end

  def and_with_a_default_performed_by_name_of_current_user
    expect(page).to have_css('.modal-performed-by .performed-by-dropdown', text: "#{@identity1.full_name}")
  end

  def when_i_save_the_modal
    find('button.save').click
  end

  def and_i_unroll_the_procedures_accordion
    find("tr.procedure-group td[colspan='8'] button.btn").click
  end

  def and_all_procedures_should_have_incompleted_date_set_to_nil
 
    procedure1_date = page.evaluate_script %Q{ $("tr.procedure[data-id='1'] div.incompleted_date_field input.datetimepicker").val(); }
    procedure2_date = page.evaluate_script %Q{ $("tr.procedure[data-id='2'] div.incompleted_date_field input.datetimepicker").val(); }
  
    expect(procedure1_date).to eq(nil)
    expect(procedure2_date).to eq(nil)
  end

  def and_all_procedures_should_have_performed_by_set_to_default
    procedure1_performed_by = page.evaluate_script %Q{ $("tr.procedure[data-id='1'] td.performed-by .selectpicker").val(); }
    procedure2_performed_by = page.evaluate_script %Q{ $("tr.procedure[data-id='2'] td.performed-by .selectpicker").val(); }

    expect(procedure1_performed_by.to_i).to eq(@identity1.id)
    expect(procedure2_performed_by.to_i).to eq(@identity1.id)
  end

  def when_i_edit_the_default_date
    page.execute_script %Q{ $("#incomplete_all_modal .datetimepicker").siblings(".input-group-addon").trigger("click");}

    tomorrow_day = evaluate_script %Q{ parseInt($("td.day.today").html())+1 }
    page.execute_script %Q{ $("#incomplete_all_modal td.day:contains(#{tomorrow_day})").last().trigger('click'); }
    
    wait_for_ajax
  end

  def and_when_i_edit_the_default_performer
    bootstrap_select ".performed-by-dropdown", @identity2.full_name
  end

  def and_all_procedures_should_have_selected_performer
    procedure1_performed_by = page.evaluate_script %Q{ $("tr.procedure[data-id='1'] td.performed-by .selectpicker").val(); }
    procedure2_performed_by = page.evaluate_script %Q{ $("tr.procedure[data-id='2'] td.performed-by .selectpicker").val(); }

    expect(procedure1_performed_by.to_i).to eq(@identity2.id)
    expect(procedure2_performed_by.to_i).to eq(@identity2.id)
  end
end
