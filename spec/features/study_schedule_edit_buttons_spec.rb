require 'rails_helper'

RSpec.describe 'Study Schedule Edit Buttons spec', type: :feature, js: true do
  let!(:protocol1)    { create(:protocol) }
  let!(:arm1)         { create(:arm, protocol_id: protocol1.id) }
  let!(:arm2)         { create(:arm, protocol_id: protocol1.id) }
  let!(:visit_group1) { create(:visit_group, arm_id: arm1.id) }
  let!(:visit_group2) { create(:visit_group, arm_id: arm2.id) }

  before :each do
    visit protocol_path(protocol1.sparc_id)
  end

  it "should render add arm modal" do
    click_link 'add_arm_button'
    wait_until(3){ page.has_css?("input[value='Add Arm']") } #wait for modal to appear
    # expect(page).to have_content "Add Arm"
  end

  it "should render add a visit modal" do
    click_link 'add_visit_button'
    wait_until(3){ page.has_css?("input[value='Add Visit']") } #wait for modal to appear
  end

  it "should change the visits displayed when the arm is changed" do
    expect(bootstrap_selected? 'arms', arm1.name).to be
    expect(bootstrap_selected? 'visits', visit_group1.name).to be
    bootstrap_select '#arms', arm2.name
    expect(bootstrap_selected? 'visits', visit_group2.name).to be
  end

  it "should add an arm and creat associated visits" do
    click_link 'add_arm_button'
    click_button 'Add Arm'
    expect(page).to have_content "Name can't be blank"
    expect(page).to have_content "Subject count is not a number"
    expect(page).to have_content "Visit count is not a number"
    fill_in 'Arm Name', with: 'arm name'
    fill_in 'Subject Count', with: 0
    fill_in 'Visit Count', with: 0
    click_button 'Add Arm'
    wait_until(3) {expect(page).to have_content "Subject count must be greater than or equal to 1"}
    expect(page).to have_content "Visit count must be greater than or equal to 1"
    fill_in 'Subject Count', with: 1
    fill_in 'Visit Count', with: 3
    click_button 'Add Arm'
    expect(page).to have_content 'Arm Created'
    bootstrap_select '#arms', 'arm name'
    expect(bootstrap_selected? 'visits', 'Visit 1').to be
  end

  it "should add a visit" do
    click_link 'add_visit_button'
    click_button 'Add Visit'
    expect(page).to have_content "Position can't be blank Name can't be blank Day can't be blank Day is not a number"
    fill_in 'Visit Name', with: "visit name"
    fill_in 'Visit Day', with: 3
    select 'add as last', from: 'visit_group_position'
    click_button 'Add Visit'
    save_and_open_screenshot
    wait_until(3) {expect(page).to have_content "Visit Created"}
  end
  it "should add a service" do
    #TODO this functionality does not exsist yet
  end

end
