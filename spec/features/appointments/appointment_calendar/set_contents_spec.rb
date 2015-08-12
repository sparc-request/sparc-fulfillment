require 'rails_helper'

feature 'Create Note', js: true do

  scenario 'User sets the content box' do
    given_i_am_viewing_an_appointment
    when_i_select_from_the_contents_dropdown
    then_i_should_be_able_to_view_the_selection
  end

  def given_i_am_viewing_an_appointment
    protocol      = create_and_assign_protocol_to_me
    @participant  = protocol.participants.first
    @appointment  = @participant.appointments.first
    @visit_group  = @appointment.visit_group
    service       = protocol.organization.inclusive_child_services(:per_participant).first

    visit participant_path @participant
    bootstrap_select '#appointment_select', @visit_group.name
  end

  def when_i_select_from_the_contents_dropdown
    bootstrap_select '#appointment_content_indications', "Space Only"
    wait_for_ajax
  end

  def then_i_should_be_able_to_view_the_selection
    visit participant_path @participant
    bootstrap_select '#appointment_select', @visit_group.name

    wait_for_ajax
    expect(page).to have_css("li.selected span.text", text: "Space Only", visible: false)
  end
end
