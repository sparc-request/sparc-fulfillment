require 'rails_helper'

RSpec.describe 'Participant Tracker', type: :feature, js: true do

  before :each do
    create_populated_protocol_data
    visit protocol_path(@protocol.sparc_id)
    click_link 'Participant Tracker'
  end

  it "should find participants" do
    expect(page).to have_css('.bootstrap-table', visible: true)
    expect(page).to have_content(@participant.first_name)
  end

  it "should find participants using the search bar" do
    participant2 = create(:participant, protocol_id: @protocol.id, first_name: 'Jack')
    click_button "Refresh" #refresh table to accomodate new participant
    wait_for_javascript_to_finish

    find('div.search > input').set(participant2.first_name) # search for participant2
    wait_for_javascript_to_finish
    expect(page).to have_content(participant2.first_name) # should find participant2
    expect(page).not_to have_content(@participant.first_name)  # should not display participant

    find('div.search > input').set('asdfghjkl') # search for gibberish
    wait_for_javascript_to_finish
    expect(page).to have_content('No matching records found') # should find no matching records
  end

  it "should render the change arm modal" do
    click_link "Change Arm"
    wait_for_javascript_to_finish
    expect(page).to have_css("input[value='Save'].btn.btn-primary", visible: true)
  end

  it "should change participant to new arm" do
    arm2 = create(:arm, protocol_id: @protocol.id, name: 'arm2')
    expect(page).to have_content(@arm.name) #should show participant on @arm

    click_link "Change Arm"
    wait_for_javascript_to_finish
    expect(page).to have_css("input[value='Save'].btn.btn-primary", visible: true)

    select arm2.name, from: 'Arm' #change to arm2
    find("input[value='Save'].btn.btn-primary").click #save
    wait_until{ page.has_no_css?("input[value='Save'].btn.btn-primary") } #wait for modal to disappear

    expect(page).to have_content('Participant Successfully Changed Arms') #expect flash message
    expect(page).to have_content(arm2.name) #should show participant on @arm
  end
end