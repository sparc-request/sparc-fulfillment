require 'rails_helper'

feature 'Identity completes all Procedures', js: true do

  before :each do
    @current_date            = DateTime.current.strftime('%m/%d/%Y')
    next_month               = Time.current.month + 1
    @the_middle_of_next_month = Date.current.strftime("0#{next_month}/15/%Y")
    @current_identity     = Identity.first
    @current_identity.update_attributes(id: 1)
    @other_identity       = create(:identity, id: 2, first_name: 'Juan', last_name: 'Leonardo')
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
    @visit_group  = @participant.appointments.first.visit_group
    @service      = protocol.organization.inclusive_child_services(:per_participant).first
    @pricing_map   = create(:pricing_map, service: @service, effective_date: @the_middle_of_next_month)

  end

  scenario 'and sees the complete buttons are active' do
    given_i_have_added_n_procedures_to_an_appointment_such_that_n_is 2
    when_i_complete_all_the_procedures
    then_i_should_see_a_complete_all_modal
    when_i_save_the_modal
    and_i_unroll_the_procedures_accordion
    then_all_the_procedure_complete_buttons_should_be_active
  end

  context 'and leaves modal defaults' do
    scenario 'sees the procedures are completed and updated with defaults' do
      given_i_have_added_n_procedures_to_an_appointment_such_that_n_is 2
      when_i_complete_all_the_procedures
      then_i_should_see_a_complete_all_modal
      with_a_default_completed_date_of_current_date
      and_with_a_default_performed_by_name_of_current_user
      when_i_save_the_modal
      and_i_unroll_the_procedures_accordion
      and_all_procedures_should_have_completed_date_set_to_default
      and_all_procedures_should_have_performed_by_set_to_default
    end
  end

  context 'edits modal defaults' do
    scenario 'and sees the procedures are completed with updated data' do
      given_i_have_added_n_procedures_to_an_appointment_such_that_n_is 2
      when_i_complete_all_the_procedures
      then_i_should_see_a_complete_all_modal
      when_i_edit_the_default_date
      and_when_i_edit_the_default_performer
      when_i_save_the_modal
      and_i_unroll_the_procedures_accordion
      and_all_procedures_should_have_selected_completed_date
      and_all_procedures_should_have_selected_performer
    end
  end

  def given_i_have_added_n_procedures_to_an_appointment_such_that_n_is number_of_procedures
    visit participant_path @participant
    wait_for_ajax

    bootstrap_select '#appointment_select', @visit_group.name
    wait_for_ajax
    
    bootstrap_select '#service_list', @service.name
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
    expected_date = page.evaluate_script %Q{ $('.date_field').first().val(); }
    expect(expected_date).to eq(DateTime.current.strftime('%m/%d/%Y'))
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

  def then_all_the_procedure_complete_buttons_should_be_active
    expect(page).to have_css('label.status.complete.active', count: 2)
  end

  def and_all_procedures_should_have_completed_date_set_to_default
    find("tr.procedure[data-id='1'] .completed_date_field")
    procedure1_date = page.evaluate_script %Q{ $("tr.procedure[data-id='1'] .completed_date_field").val(); }

    find("tr.procedure[data-id='2'] .completed_date_field")
    procedure2_date = page.evaluate_script %Q{ $("tr.procedure[data-id='2'] .completed_date_field").val(); }
  
    expect(procedure1_date).to eq(@current_date)
    expect(procedure2_date).to eq(@current_date)
  end

  def and_all_procedures_should_have_performed_by_set_to_default

    find("tr.procedure[data-id='1'] td.performed-by .selectpicker")
    procedure1_performed_by = page.evaluate_script %Q{ $("tr.procedure[data-id='1'] td.performed-by .selectpicker").val(); }

    find("tr.procedure[data-id='2'] td.performed-by .selectpicker")
    procedure2_performed_by = page.evaluate_script %Q{ $("tr.procedure[data-id='2'] td.performed-by .selectpicker").val(); }
    puts "*"*100
    puts procedure1_performed_by.to_i
    puts procedure2_performed_by.to_i
    puts @other_identity.id
    puts "*"*100
    expect(procedure1_performed_by.to_i).to eq(@current_identity.id)
    expect(procedure2_performed_by.to_i).to eq(@current_identity.id)
  end

  def when_i_edit_the_default_date
    page.execute_script %Q{ $('.date_field').trigger('click'); }
    next_month               = Time.current.month + 1
    edited_completed_date = Date.current.strftime("0#{next_month}/15/%Y")
    page.execute_script %Q{ $(".date_field").val('#{edited_completed_date}') }

    wait_for_ajax
  end

  def and_when_i_edit_the_default_performer
    complete_all_modal = page.find("#complete_all_modal")
    within complete_all_modal do
      bootstrap_select ".performed-by-dropdown", @other_identity.full_name
    end
    wait_for_ajax
  end

  def and_all_procedures_should_have_selected_completed_date
    find("tr.procedure[data-id='1'] .completed_date_field")
    procedure1_date = page.evaluate_script %Q{ $("tr.procedure[data-id='1'] .completed_date_field").val(); }

    find("tr.procedure[data-id='2'] .completed_date_field")
    procedure2_date = page.evaluate_script %Q{ $("tr.procedure[data-id='2'] .completed_date_field").val(); }
  
    expect(procedure1_date).to eq(@the_middle_of_next_month)
    expect(procedure2_date).to eq(@the_middle_of_next_month)
  end

  def and_all_procedures_should_have_selected_performer
    find("tr.procedure[data-id='1'] td.performed-by .selectpicker")
    procedure1_performed_by = page.evaluate_script %Q{ $("tr.procedure[data-id='1'] td.performed-by .selectpicker").val(); }

    find("tr.procedure[data-id='2'] td.performed-by .selectpicker")
    procedure2_performed_by = page.evaluate_script %Q{ $("tr.procedure[data-id='2'] td.performed-by .selectpicker").val(); }
    puts "*"*100
    puts procedure1_performed_by.to_i
    puts procedure2_performed_by.to_i
    puts @other_identity.id
    puts "*"*100
    expect(procedure1_performed_by.to_i).to eq(@other_identity.id)
    expect(procedure2_performed_by.to_i).to eq(@other_identity.id)
  end

  def when_i_select_nil_for_competed_date
    find('#complete_all_modal')
    page.execute_script %Q{ $('#complete_all_modal').val(''); }
  end

end
