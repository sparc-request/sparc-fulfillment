require 'rails_helper'

RSpec.describe 'Study Schedule Edit Buttons spec', type: :feature, js: true do
  let!(:protocol1)    { create(:protocol) }
  let!(:arm1)         { create(:arm_with_visit_groups, protocol_id: protocol1.id) }
  let!(:arm2)         { create(:arm_with_visit_groups, protocol_id: protocol1.id) }
  let!(:service1)     { create(:service) }

  before :each do
    visit protocol_path(protocol1.sparc_id)
  end

  it "should render add arm modal" do
    click_link 'add_arm_button'
    expect(page).to have_content "Add Arm"

  end

  it "should render add a visit modal" do
    click_link 'add_visit_button'
    expect(page).to have_content 'Add Visit'
  end

  it "should change the visits displayed when the arm is changed" do
    expect(bootstrap_selected? 'arms', arm1.name).to be
    expect(bootstrap_selected? 'visits', arm1.visit_groups.first.name).to be
    bootstrap_select '#arms', arm2.name
    expect(bootstrap_selected? 'visits', arm2.visit_groups.first.name).to be
  end

  it "should add an arm and create associated visits" do
    click_link 'add_arm_button'
    click_button 'Add Arm'
    expect(page).to have_content "Name can't be blank"
    expect(page).to have_content "Subject count is not a number"
    expect(page).to have_content "Visit count is not a number"
    fill_in 'Arm Name', with: 'arm name'
    fill_in 'Subject Count', with: 0
    fill_in 'Visit Count', with: 0
    click_button 'Add Arm'
    expect(page).to have_content "Subject count must be greater than or equal to 1"
    expect(page).to have_content "Visit count must be greater than or equal to 1"
    fill_in 'Subject Count', with: 1
    fill_in 'Visit Count', with: 3
    click_button 'Add Arm'
    expect(page).to have_content 'Arm Created'
    bootstrap_select '#arms', 'arm name'
    expect(bootstrap_selected? 'visits', 'Visit 0').to be
  end

  it "should add a visit" do
    create(:line_item, arm_id: arm1.id, service_id: service1.id)
    visit current_path
    click_link 'add_visit_button'
    click_button 'Add'
    wait_for_javascript_to_finish
    expect(page).to have_content "Name can't be blank Day can't be blank Day is not a number"
    fill_in 'Visit Name', with: "visit name"
    fill_in 'Visit Day', with: 3
    click_button 'Add'
    wait_until(3) {expect(page).to have_content "Visit Created"}
    #since only 5 visit groups are created on the factory default arm the addition of one should show up on the selected page
    wait_for_javascript_to_finish
    expect(page).to have_css ".visit_name[value='visit name']"
  end

  it "should add a service to one or multiple arms" do
    click_link 'add_service_button'
    wait_for_javascript_to_finish
    expect(page).to have_content "Add a Service"
    select service1.name, from: "service_id"
    find(:css,"#arm_ids_[value='#{arm1.id}']").set(true)
    find(:css,"#arm_ids_[value='#{arm2.id}']").set(true)
    click_button 'Add Service'
    expect(page).to have_content "Service(s) have been added to the chosen arms"
  end

  it "should remove service from one or more arms" do
    click_link 'remove_service_button'
    expect(page).to have_content "Remove Services"
    select service1.name, from: "service_id"
    find(:css,"#arm_ids_[value='#{arm1.id}']").set(true)
    find(:css,"#arm_ids_[value='#{arm2.id}']").set(true)
    click_button 'Remove'
    wait_for_javascript_to_finish
    expect(page).to have_content "Service(s) have been removed from the chosen arms"
  end
end
