require 'rails_helper'

feature 'User changes Participant Arm', js: true do

  scenario 'and sees the updated Participant' do
    given_i_am_viewing_the_participant_tracker
    when_i_change_a_participants_arm
    then_i_should_see_the_arm_is_updated
  end

  def given_i_am_viewing_the_participant_tracker
    protocol    = create_and_assign_protocol_to_me
    @second_arm  = protocol.arms.second

    visit protocol_path(protocol.id)

    click_link 'Participant Tracker'
  end

  def when_i_change_a_participants_arm
    page.find('table.participants tbody tr:first-child td.change_arm a').click
    
    select @second_arm.name, from: 'Current Arm'

    click_button 'Save'
  end

  def then_i_should_see_the_arm_is_updated
    expect(page).to have_css('#flashes_container', text: 'Participant Successfully Changed Arms')
    expect(page).to have_css('table.participants tbody tr:first-child td.arm_name', text: @second_arm.name)
  end
end
