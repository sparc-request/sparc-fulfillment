require 'rails_helper'

feature 'User tries to reset appointment', js: true do

  scenario 'and sees the appointment reset' do
    given_i_am_viewing_a_participants_calendar_with_procedures
    when_i_start_the_appointment
    when_i_resolve_all_procedures
    when_i_complete_the_visit
    when_i_click_the_reset_button
    then_i_should_see_a_reset_appointment
  end

  def given_i_am_viewing_a_participants_calendar_with_procedures
    @protocol     = create_and_assign_protocol_to_me
    arm           = @protocol.arms.first
    @participant  = Participant.first
    @visit_group  = arm.visit_groups.first
    @appointment  = @visit_group.appointments.where(participant_id: @participant).first
    line_item_1   = arm.line_items[0]

    #Add services for the visit group
    visit protocol_path(@protocol.id)
    wait_for_ajax
    find("#line_item_#{line_item_1.id} .check_row").click()
    wait_for_ajax

    #Select the visit
    visit participant_path(Participant.first.id)
    wait_for_ajax
    bootstrap_select('#appointment_select', VisitGroup.first.name)
    wait_for_ajax
  end

  def when_i_start_the_appointment
    find('button.start_visit').click
    wait_for_ajax
  end

  def when_i_resolve_all_procedures
    page.all('label.btn.complete.status').each do |btn|
      btn.click
      wait_for_ajax
    end
  end

  def when_i_complete_the_visit
    find("button.complete_visit").click
    wait_for_ajax
  end

  def when_i_click_the_reset_button
    find("button.reset_visit").click
    wait_for_ajax
  end

  def then_i_should_see_a_reset_appointment
    expect(page).to have_css('button.start_visit', visible: true)
    expect(page).to have_css('button.complete_visit.disabled', visible: true)
    expect(page).to have_css('td.status .pre_start_disabled', visible: true)
  end
end
