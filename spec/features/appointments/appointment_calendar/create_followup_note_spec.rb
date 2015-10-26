require 'rails_helper'

feature 'Followup note', js: true do

  context 'User starts an appointment' do
    scenario 'and sees the followup button' do
      given_i_have_created_a_procedure
      when_i_begin_an_appointment
      then_i_should_see_the_followup_button
    end

    context 'and creates a followup' do
      scenario 'and sees the followup date' do
        given_i_have_created_a_procedure
        when_i_begin_an_appointment
        when_i_click_the_followup_button
        when_i_fill_out_and_submit_the_followup_form
        then_i_should_see_a_text_field_with_the_followup_date
      end

      context 'and creates a followup note' do
        scenario 'and sees the note in the notes list' do
          given_i_have_created_a_procedure
          given_i_have_created_a_followup_note
          when_i_view_the_notes_list
          then_i_should_see_the_note_i_created
        end

        scenario 'and sees the new respective task on the tasks page' do
          given_i_have_created_a_procedure
          given_i_have_created_a_followup_note
          when_i_visit_the_tasks_index_page
          then_i_should_see_the_newly_created_task
        end

        context 'and edits the followup date on the calendar' do
          scenario 'and sees the followup date change' do
            given_i_have_created_a_procedure
            given_i_have_created_a_followup_note
            then_i_should_be_able_to_edit_the_followup_date
            then_i_should_see_the_date_change
          end
        end
      end
    end
  end

  context 'User does not start an appointment' do
    scenario 'and sees the followup button' do
      given_i_have_created_a_procedure
      then_i_should_see_the_followup_button
    end

    context 'and tries to add a followup note' do
      scenario 'and sees a helpful error message' do
        given_i_have_created_a_procedure
        when_i_try_to_add_a_follow_up_note
        then_i_should_see_a_helpful_message
      end
    end
  end

  def given_i_have_created_a_procedure
    protocol    = create_and_assign_protocol_to_me
    @assignee   = Identity.first
    participant = protocol.participants.first
    visit_group = participant.appointments.first.visit_group
    service     = protocol.organization.inclusive_child_services(:per_participant).first

    visit participant_path participant
    bootstrap_select '#appointment_select', visit_group.name
    bootstrap_select '#service_list', service.name
    fill_in 'service_quantity', with: '1'
    find('button.add_service').click
    wait_for_ajax

    @procedure = visit_group.appointments.first.procedures.where(service_id: service.id).first
  end

  def given_i_have_created_a_followup_note
    when_i_begin_an_appointment
    when_i_click_the_followup_button
    when_i_fill_out_and_submit_the_followup_form
  end

  def when_i_begin_an_appointment
    find('button.start_visit').click
    wait_for_ajax
  end

  def when_i_click_the_followup_button
    find('button.followup.new').click
  end

  def when_i_fill_out_and_submit_the_followup_form
    bootstrap_select '#task_assignee_id', @assignee.full_name
    page.execute_script %Q{ $("#follow_up_procedure_datepicker").children(".input-group-addon").trigger("click")}
    page.execute_script %Q{ $("td.day:contains('10')").trigger("click") }
    fill_in 'Comment', with: 'Test comment'
    click_button 'Save'
    wait_for_ajax
  end

  def when_i_view_the_notes_list
    find('.procedure td.notes button.notes.list').click
  end

  def when_i_visit_the_tasks_index_page
    visit tasks_path
  end

  def when_i_try_to_add_a_follow_up_note
    @alert = accept_alert(with: 'Please click Start Visit and enter a start date to continue.') do
      find('button.followup.new').trigger('click')
    end
  end

  def then_i_should_see_the_followup_button
    expect(page).to have_css('button.followup.new')
  end

  def then_i_should_see_a_text_field_with_the_followup_date
    procedure = Procedure.first
    expect(page).to have_css("input#follow_up_datepicker_#{procedure.id}[value='#{Time.new(Time.now.year,Time.now.month,10).strftime("%m/%d/%Y")}']")
  end

  def then_i_should_see_the_note_i_created
    expect(page).to have_css('.modal-body .comment', text: 'Test comment')
  end

  def then_i_should_see_the_newly_created_task
    expect(page).to have_css("table.tasks tbody td.body", text: "Test comment")
  end

  def then_i_should_be_able_to_edit_the_followup_date
    page.execute_script %Q{ $(".followup_procedure_datepicker").children(".input-group-addon").trigger("click")}
    page.execute_script %Q{ $("td.day:contains('15')").trigger("click") }
    wait_for_ajax
  end

  def then_i_should_see_the_date_change
    expect(@procedure.task.due_at.strftime("%m/%d/%Y")).to eq Time.new(Time.now.year,Time.now.month,15).strftime("%m/%d/%Y")
  end

  def then_i_should_see_a_helpful_message
    expect(@alert).to eq("Please click 'Start Visit' and enter a start date to continue.")
  end
end
