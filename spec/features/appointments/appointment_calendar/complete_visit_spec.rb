require 'rails_helper'

feature 'Complete Visit', js: true do
  before(:each) do
    go_to_visit
  end

  context 'Appointment has not begun' do

    scenario 'User adds a Procedure' do
      as_a_user_who_adds_a_procedure_to_an_appointment
      i_should_not_be_able_to_complete_visit
    end

    scenario 'User adds no Procedure' do
      i_should_not_be_able_to_complete_visit
    end

    scenario 'User adds a Procedure, then removes it' do
      as_a_user_who_adds_a_procedure_to_an_appointment
      then_removes_procedure
      i_should_not_be_able_to_complete_visit
    end
  end

  context 'Appointment has begun' do

    context 'Procedures include a Procedure marked neither complete nor incomplete' do

      before(:each) do
        add_a_procedure
      end

      scenario 'User adds a Procedure' do
        as_a_user_who_adds_a_procedure_to_an_appointment
        then_begins_appointment
        i_should_not_be_able_to_complete_visit
      end

      scenario 'User adds a Procedure, then sets a follow up date for it' do
        as_a_user_who_adds_a_procedure_to_an_appointment
        then_begins_appointment
        then_adds_a_follow_up_date
        i_should_not_be_able_to_complete_visit
      end

      scenario 'User adds a Procedure, then completes it' do
        as_a_user_who_adds_a_procedure_to_an_appointment
        then_begins_appointment
        then_completes_procedure
        i_should_not_be_able_to_complete_visit
      end

      scenario 'User adds a Procedure, then incompletes it' do
        as_a_user_who_adds_a_procedure_to_an_appointment
        then_begins_appointment
        then_incompletes_procedure
        i_should_not_be_able_to_complete_visit
      end

      scenario 'User adds a Procedure, completes it, then incompletes it' do
        as_a_user_who_adds_a_procedure_to_an_appointment
        then_begins_appointment
        then_completes_procedure
        then_incompletes_procedure
        i_should_not_be_able_to_complete_visit
      end

      scenario 'User adds no Procedure' do
        as_a_user_who_begins_an_appointment
        i_should_not_be_able_to_complete_visit
      end

      scenario 'User adds a Procedure, then removes it' do
        as_a_user_who_adds_a_procedure_to_an_appointment
        then_begins_appointment
        then_removes_procedure
        i_should_not_be_able_to_complete_visit
      end
    end

    context 'Procedures do not include a Procedure marked neither complete nor incomplete' do

      scenario 'User adds a Procedure' do
        as_a_user_who_adds_a_procedure_to_an_appointment
        then_begins_appointment
        i_should_not_be_able_to_complete_visit
      end

      scenario 'User adds a Procedure, then sets a follow up date for it' do
        as_a_user_who_adds_a_procedure_to_an_appointment
        then_begins_appointment
        then_adds_a_follow_up_date
        i_should_be_able_to_complete_visit
      end

      scenario 'User adds a Procedure, then completes it' do
        as_a_user_who_adds_a_procedure_to_an_appointment
        then_begins_appointment
        then_completes_procedure
        i_should_be_able_to_complete_visit
      end

      scenario 'User adds a Procedure, then incompletes it' do
        as_a_user_who_adds_a_procedure_to_an_appointment
        then_begins_appointment
        then_incompletes_procedure
        i_should_be_able_to_complete_visit
      end

      scenario 'User adds a Procedure, completes it, then incompletes it' do
        as_a_user_who_adds_a_procedure_to_an_appointment
        then_begins_appointment
        then_completes_procedure
        then_incompletes_procedure
        i_should_be_able_to_complete_visit
      end

      scenario 'User adds no Procedure' do
        as_a_user_who_begins_an_appointment
        i_should_be_able_to_complete_visit
      end

      scenario 'User adds a Procedure, then removes it' do
        as_a_user_who_adds_a_procedure_to_an_appointment
        then_begins_appointment
        then_removes_procedure
        i_should_be_able_to_complete_visit
      end
    end
  end

  def go_to_visit
    protocol     = create(:protocol_imported_from_sparc)
    participant  = protocol.participants.first
    @visit_group = participant.appointments.first.visit_group
    @service     = Service.per_patient.first

    visit participant_path participant
    bootstrap_select '#appointment_select', @visit_group.name
    wait_for_ajax
  end

  def begin_appointment
    find('button.start_visit').click
    wait_for_ajax
  end

  def i_should_not_be_able_to_complete_visit
    accept_alert do
      find("button.complete_visit.disabled").trigger('click')
    end
  end

  def i_should_be_able_to_complete_visit
    expect(page).not_to have_css("button.complete_visit.disabled")
    find("button.complete_visit").click
    wait_for_ajax
    # completed date input should be visible after clicking Complete Visit
    expect(page).not_to have_css('div.completed_date_input.hidden')
  end

  def then_completes_procedure
    find("tr[data-id='#{@procedure.id}'] label.status.complete").click
    wait_for_ajax
  end

  def then_incompletes_procedure
    find("tr[data-id='#{@procedure.id}'] label.status.incomplete").click
    click_button "Save"
    wait_for_ajax
  end

  def add_a_procedure
    bootstrap_select '#service_list', @service.name
    fill_in 'service_quantity', with: 1
    find('button.add_service').click
    wait_for_ajax

    @visit_group.appointments.first.procedures.reload
    @procedure = @visit_group.appointments.first.procedures.where(service_id: @service.id).first
  end

  def then_adds_a_follow_up_date
    find("tr[data-id='#{@procedure.id}'] button.followup.new").click
    wait_for_ajax

    bootstrap_select '#task_assignee_id', @clinical_providers.first.identity.full_name

    page.execute_script %Q{ $("#follow_up_procedure_datepicker").children(".input-group-addon").trigger("click")}
    page.execute_script %Q{ $("td.day:contains('10')").trigger("click") }
    fill_in 'Comment', with: 'Test comment'
    click_button 'Save'
    wait_for_ajax
  end

  def then_removes_procedure
    accept_confirm do
      find("tr[data-id='#{@procedure.id}'] button.delete").click
    end
    wait_for_ajax
  end

  alias :as_a_user_who_begins_an_appointment :begin_appointment
  alias :then_begins_appointment             :begin_appointment
  alias :as_a_user_who_adds_a_procedure_to_an_appointment :add_a_procedure
end
