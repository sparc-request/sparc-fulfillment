require 'rails_helper'

feature 'Identity adds Procedure', js: true do

  context 'User adds two procedures' do
    scenario 'and sees them in the appointment calendar' do
      given_i_am_viewing_a_participants_calendar
      when_i_add_two_procedures
      then_i_should_see_two_procedures_in_the_appointment_calendar
    end
  end

  def given_i_am_viewing_a_participants_calendar
    @protocol     = create_and_assign_protocol_to_me
    @participant  = @protocol.participants.first

    visit participant_path(@participant)
    wait_for_ajax
  end

  def when_i_add_two_procedures
    visit_group = @participant.appointments.first.visit_group
    service     = @protocol.organization.inclusive_child_services(:per_participant).first

    bootstrap_select('#appointment_select', visit_group.name)
    wait_for_ajax
    bootstrap_select('#service_list', service.name)
    fill_in 'service_quantity', with: '2'
    page.find('button.add_service').click
    wait_for_ajax
  end

  def then_i_should_see_two_procedures_in_the_appointment_calendar
    expect(page).to have_css('.procedures .procedure', count: 2)
  end
end
