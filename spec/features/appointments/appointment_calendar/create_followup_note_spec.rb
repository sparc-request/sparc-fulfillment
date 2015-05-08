require 'rails_helper'

feature 'Followup note', js: true do

  scenario 'User views followup button' do
    as_a_user_who_has_created_a_procedure
    i_should_see_the_followup_button
  end

  scenario 'User creates followup note' do
    as_a_user_who_has_created_a_procedure
    when_i_click_the_followup_button
    and_i_fill_out_and_submit_the_followup_form
    then_i_should_see_a_text_field_with_the_followup_date
  end

  scenario 'User views Notes list after creating a followup note' do
    as_a_user_who_has_created_a_followup_note
    when_i_view_the_notes_list
    i_should_see_the_note_i_created
  end

  scenario 'User views Tasks list after creating a followup note' do
    as_a_user_who_has_created_a_followup_note
    when_i_visit_the_tasks_index_page
    then_i_should_see_the_newly_created_task
  end

  scenario 'User edits follow up date on the calendar' do
    as_a_user_who_has_created_a_followup_note
    i_should_be_able_to_edit_the_followup_date
    and_the_date_should_change
  end

  def when_i_visit_the_tasks_index_page
    visit tasks_path
  end

  def i_should_be_able_to_edit_the_followup_date
    page.execute_script %Q{ $(".followup_procedure_datepicker").children(".input-group-addon").trigger("click")}
    page.execute_script %Q{ $("td.day:contains('15')").trigger("click") }
    wait_for_ajax
  end

  def and_the_date_should_change
    expect(@procedure.task.due_at.strftime("%m/%d/%Y")).to eq Time.new(Time.now.year,Time.now.month,15).strftime("%m/%d/%Y")
  end

  def then_i_should_see_the_newly_created_task
    expect(page).to have_css("table.tasks tbody td.body", text: "Test comment")
  end

  def as_a_user_who_has_created_a_procedure
    protocol    = create(:protocol_imported_from_sparc)
    participant = protocol.participants.first
    visit_group = participant.appointments.first.visit_group
    service     = Service.first
    @assignee   = User.first

    visit participant_path participant
    bootstrap_select '#appointment_select', visit_group.name
    find("#service_list > option[value='#{service.id}']").select_option
    fill_in 'service_quantity', with: '1'
    find('button.add_service').click
    wait_for_ajax

    @procedure = visit_group.appointments.first.procedures.where(service_id: service.id).first
  end

  def when_i_click_the_followup_button
    find('button.followup.new').click
  end

  def and_i_fill_out_and_submit_the_followup_form
    select @assignee.full_name, from: 'task_assignee_id'
    page.execute_script %Q{ $("#follow_up_procedure_datepicker").children(".input-group-addon").trigger("click")}
    page.execute_script %Q{ $("td.day:contains('10')").trigger("click") }
    fill_in 'Comment', with: 'Test comment'
    click_button 'Save'
    wait_for_ajax
  end

  def as_a_user_who_has_created_a_followup_note
    as_a_user_who_has_created_a_procedure
    when_i_click_the_followup_button
    and_i_fill_out_and_submit_the_followup_form
  end

  def when_i_view_the_notes_list
    find('.procedure td.notes button.notes.list').click
  end

  def i_should_see_the_note_i_created
    expect(page).to have_css('.modal-body .comment', text: 'Test comment')
  end

  def then_i_should_see_a_text_field_with_the_followup_date
    procedure = Procedure.first
    expect(page).to have_css("input#follow_up_datepicker_#{procedure.id}[value='#{Time.new(Time.now.year,Time.now.month,10).strftime("%m/%d/%Y")}']")
  end

  def i_should_see_the_followup_button
    expect(page).to have_css('button.followup.new')
  end
end
