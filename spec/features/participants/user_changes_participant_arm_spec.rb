require 'rails_helper'

feature 'User changes Participant Arm', js: true do

  scenario 'and sees the updated Participant' do
    protocol    = create(:protocol_imported_from_sparc)
    second_arm  = protocol.arms.second

    visit protocol_path(protocol.sparc_id)
    click_link 'Participant Tracker'
    page.find('table.participants tbody tr:first-child td.change_arm a').click
    select second_arm.name, from: 'Current Arm'
    click_button 'Save'

    expect(page).to have_css('#flashes_container', text: 'Participant Successfully Changed Arms')
    expect(page).to have_css('table.participants tbody tr:first-child td.arm_name', text: second_arm.name)
  end
end
