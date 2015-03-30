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

  def as_a_user_who_has_created_a_procedure
    protocol    = create(:protocol_imported_from_sparc)
    participant = protocol.participants.first
    visit_group = participant.appointments.first.visit_group
    service     = Service.first

    visit participant_path participant
    bootstrap_select '#appointment_select', visit_group.name
    find("#service_list > option[value='#{service.id}']").select_option
    fill_in 'service_quantity', with: '1'
    find('button.add_service').click
  end

  def when_i_click_the_followup_button
    find('button.followup.new').click
  end

  def and_i_fill_out_and_submit_the_followup_form
    fill_in 'procedure_follow_up_date', with: '2015-03-11'
    fill_in 'Comment', with: 'Test comment'
    click_button 'Save'
  end

  def as_a_user_who_has_created_a_followup_note
    as_a_user_who_has_created_a_procedure
    when_i_click_the_followup_button
    and_i_fill_out_and_submit_the_followup_form
  end

  def when_i_view_the_notes_list
    find('button.notes.list').click
  end

  def i_should_see_the_note_i_created
    expect(page).to have_css('.modal-body .comment', text: 'Test comment')
  end

  def then_i_should_see_a_text_field_with_the_followup_date
    procedure = Procedure.first
    value     = evaluate_script("$('.date#procedure_#{procedure.id}').data('date');")

    expect(value).to eq('2015-03-11')
  end

  def i_should_see_the_followup_button
    expect(page).to have_css('button.followup.new')
  end
end
