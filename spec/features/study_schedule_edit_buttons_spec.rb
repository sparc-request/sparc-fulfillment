require 'rails_helper'

RSpec.describe 'Study Schedule Edit Buttons spec', type: :feature, js: true do
  let!(:protocol1)    { create(:protocol_with_pi) }
  let!(:arm1)         { create(:arm_imported_from_sparc, protocol_id: protocol1.id, visit_count: 5) }
  let!(:arm2)         { create(:arm_imported_from_sparc, protocol_id: protocol1.id, visit_count: 1) }
  let!(:service1)     { Service.first }

  before :each do
    visit protocol_path(protocol1.sparc_id)
    # wait_for_javascript_to_finish
  end

  describe "arm buttons" do
    describe "the add arm button" do

      it "should render an add arm modal" do
        find('#add_arm_button').click()
        expect(page).to have_css ("#add_arm")
      end

      it "should validate fields on the add arm form" do
        find('#add_arm_button').click()
        click_button 'Add Arm'
        expect(page).to have_content "Name can't be blank"
        expect(page).to have_content "Subject count is not a number"
        expect(page).to have_content "Visit count is not a number"
        fill_in 'Subject Count', with: 0
        fill_in 'Visit Count', with: 0
        click_button 'Add Arm'
        expect(page).to have_content "Subject count must be greater than or equal to 1"
        expect(page).to have_content "Visit count must be greater than or equal to 1"
      end

      it "should add an arm without services" do
        find('#add_arm_button').click()
        fill_in 'Arm Name', with: 'arm name'
        fill_in 'Subject Count', with: 1
        fill_in 'Visit Count', with: 3
        click_button 'Add Arm'
        expect(page).to have_content 'Arm Created'
        new_arm = all(".calendar.service").last()
        wait_for_javascript_to_finish
        expect(new_arm).not_to have_css ".row.line_item"
      end

      it "should add an arm with services" do
        find('#add_arm_button').click()
        fill_in 'Arm Name', with: 'arm name'
        find(:css, "#services_[value='#{service1.id}']").set(true)
        fill_in 'Subject Count', with: 1
        fill_in 'Visit Count', with: 3
        click_button 'Add Arm'
        expect(page).to have_content 'Arm Created'
        new_arm = all(".calendar.service").last()
        wait_for_javascript_to_finish
        expect(new_arm).to have_css ".row.line_item"
      end

      it "should create visits with an arm" do
        find('#add_arm_button').click()
        fill_in 'Arm Name', with: 'arm name'
        fill_in 'Subject Count', with: 1
        fill_in 'Visit Count', with: 3
        click_button 'Add Arm'
        bootstrap_select '#arms', 'arm name'
        expect(bootstrap_selected? 'visits', 'Visit 0').to be
      end

      it "should add the arm to the service calendar" do
        find('#add_arm_button').click()
        fill_in 'Arm Name', with: 'arm name'
        fill_in 'Subject Count', with: 1
        fill_in 'Visit Count', with: 3
        click_button 'Add Arm'
        wait_for_javascript_to_finish
        expect(page).to have_content "Arm: arm name"
      end
    end

    describe "the remove arm button" do
      it "should remove an arm" do
        find('#remove_arm_button').click()
        page.driver.browser.accept_js_confirms
        expect(page).to have_content "Arm Destroyed"
      end

      it "should remove the arm from the service calendar" do
        find('#remove_arm_button').click()
        page.driver.browser.accept_js_confirms
        wait_for_javascript_to_finish
        expect(page).to have_content "Arm Destroyed"
        expect(page).not_to have_content "Arm: #{arm1.name}"
      end
    end
  end

  describe "visit group buttons" do
    it "should change the visits displayed when the arm is changed" do
      expect(bootstrap_selected? 'arms', arm1.name).to be
      expect(bootstrap_selected? 'visits', arm1.visit_groups.first.name).to be
      bootstrap_select '#arms', arm2.name
      expect(bootstrap_selected? 'visits', arm2.visit_groups.first.name).to be
    end

    describe "the add visit group button" do
      it "should validate the visit group form" do
        create(:line_item, arm_id: arm1.id, service_id: service1.id)
        visit current_path
        find('#add_visit_button').click()
        click_button 'Add'
        wait_for_javascript_to_finish
        expect(page).to have_content "Name can't be blank Day can't be blank Day is not a number"
      end

      it "should add a valid visit group" do
        find('#add_visit_button').click()
        fill_in 'Visit Name', with: "visit name"
        fill_in 'Visit Day', with: 3
        click_button 'Add'
        wait_for_javascript_to_finish
        expect(page).to have_content "Visit Created"
      end

      it "should add a visit group to the service calendar" do
        find('#add_visit_button').click()
        fill_in 'Visit Name', with: "visit name"
        fill_in 'Visit Day', with: 3
        select "insert before #{arm1.visit_groups.first.name}", from: 'visit_group_position'
        click_button 'Add'
        expect(page).to have_css ".visit_group_0[value='visit name']"
      end
    end

    describe "the remove visit group button" do
      it "should remove a visit group" do
        find('#remove_visit_button').click()
        page.driver.browser.accept_js_confirms
        wait_for_javascript_to_finish
        expect(page).to have_content "Visit Destroyed"
      end

      it "should remove all but the last visit group" do
        bootstrap_select "#arms", "#{arm2.name}"
        wait_for_javascript_to_finish
        find('#remove_visit_button').click()
        page.driver.browser.accept_js_confirms
        wait_for_javascript_to_finish
        expect(page).to have_content "Arms must have at least one visit. Add another visit before deleting this one"
      end

      it "should remove the visit group from the service calendar" do
        page.driver.browser.accept_js_confirms
        vg_id = arm1.visit_groups.first.id
        bootstrap_select "#visits", "#{arm1.visit_groups.first.name}"
        find('#remove_visit_button').click()
        expect(page).not_to have_css "#visit_group_#{vg_id}"
      end
    end
  end

  describe "services" do

    describe 'add modal' do
      it "should add a service to one or multiple arms" do
        expect(page).not_to have_css("div#arm_#{arm1.id}_core_#{service1.sparc_core_id}")
        expect(page).not_to have_css("div#arm_#{arm2.id}_core_#{service1.sparc_core_id}")
        find('#add_service_button').click()
        wait_for_javascript_to_finish
        expect(page).to have_content "Add a Service"
        select service1.name, from: "service_id"
        find(:css,"#arm_ids_[value='#{arm1.id} 1']").set(true)
        find(:css,"#arm_ids_[value='#{arm2.id} 1']").set(true)
        click_button 'Add Service'
        wait_for_javascript_to_finish
        expect(page).to have_content "Service(s) have been added to the chosen arms"
        expect(page).to have_css("div#arm_#{arm1.id}_core_#{service1.sparc_core_id}")
        expect(page).to have_css("div#arm_#{arm2.id}_core_#{service1.sparc_core_id}")
      end
    end

    describe 'remove modal' do

      before :each do
        li_1 = create(:line_item, arm: arm1, service: service1)
        li_2 = create(:line_item, arm: arm2, service: service1)
        visit current_path
      end

      it "should remove service from one or more arms" do
        expect(page).to have_css("div#arm_#{arm1.id}_core_#{service1.sparc_core_id}")
        expect(page).to have_css("div#arm_#{arm2.id}_core_#{service1.sparc_core_id}")
        find('#remove_service_button').click()
        expect(page).to have_content "Remove Services"
        select service1.name, from: "service_id"
        find(:css,"#arm_ids_[value='#{arm1.id} 1']").set(true)
        find(:css,"#arm_ids_[value='#{arm2.id} 1']").set(true)
        click_button 'Remove'
        wait_for_javascript_to_finish
        expect(page).to have_content "Service(s) have been removed from the chosen arms"
        expect(page).not_to have_css("div#arm_#{arm1.id}_core_#{service1.sparc_core_id}")
        expect(page).not_to have_css("div#arm_#{arm2.id}_core_#{service1.sparc_core_id}")
      end

      it 'dropdown should populate only with currently added services' do
        find('#remove_service_button').click()
        assert_selector("#service_id > option", count: 1)
      end

      it 'arm checkbox should only display if service selected is on arm' do
        find('#remove_service_button').click()
        assert_selector(".arm-checkbox > label", count: 2)
      end
    end
  end
end
