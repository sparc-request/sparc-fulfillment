require 'rails_helper'

RSpec.describe 'Study Schedule Edit Buttons spec', type: :feature, js: true do

  before :each do
    @protocol   = create_and_assign_protocol_to_me
    @arm1       = @protocol.arms.first
    @arm2       = @protocol.arms.last
    @arm3       = create(:arm_with_one_visit_group, protocol: @protocol)
    @service    = @protocol.organization.inclusive_child_services(:per_participant).first

    visit protocol_path(@protocol.id)
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
        new_arm = Arm.find_by_name('arm name')
        expect(new_arm.line_items.count).to eq(0)
      end

      it "should add an arm with services" do
        find('#add_arm_button').click()
        fill_in 'Arm Name', with: 'arm name'
        first("#services_").set(true)
        fill_in 'Subject Count', with: 1
        fill_in 'Visit Count', with: 3
        click_button 'Add Arm'
        expect(page).to have_content 'Arm Created'
        new_arm = Arm.find_by_name('arm name')
        expect(new_arm.line_items.count).to eq(1)
      end

      it "should create visits with an arm" do
        find('#add_arm_button').click()
        fill_in 'Arm Name', with: 'arm name'
        fill_in 'Subject Count', with: 1
        fill_in 'Visit Count', with: 3
        click_button 'Add Arm'
        wait_for_ajax
        new_arm = Arm.find_by_name('arm name')
        expect(new_arm.visit_groups.count).to eq(3)
      end

      it "should add the arm to the @service calendar" do
        find('#add_arm_button').click()
        fill_in 'Arm Name', with: 'arm name'
        fill_in 'Subject Count', with: 1
        fill_in 'Visit Count', with: 3
        click_button 'Add Arm'
        expect(page).to have_content "arm name"
      end
    end

    describe "the remove arm button" do
      it "should remove an arm" do
        find('#remove_arm_button').click()
        page.driver.browser.accept_js_confirms
        expect(page).to have_content "Arm Destroyed"
      end

      it "should should not remove all arms" do
        @protocol.arms.count.times do
          find('#remove_arm_button').click()
          page.driver.browser.accept_js_confirms
        end
        expect(page).to_not have_content "Nothing selected"
      end

      it "should remove the arm from the @service calendar" do
        find('#remove_arm_button').click()
        page.driver.browser.accept_js_confirms
        expect(page).to have_content "Arm Destroyed"
        expect(page).not_to have_content "Arm: #{@arm1.name}"
      end
    end

    describe "the edit arm button" do

      it "should update the arm" do
        bootstrap_select "#arms", "#{@arm1.name}"
        find('#edit_arm_button').click()
        wait_for_ajax
        fill_in 'Arm Name', with: 'New Name'
        click_button 'Submit'
        wait_for_ajax
        expect(page).to have_content "New Name"
      end
    end
  end

  describe "visit group buttons" do

    describe "the add visit group button" do

      it "should validate the visit group form" do
        find('#add_visit_group_button').click()
        click_button 'Add'
        expect(page).to have_content "Name can't be blank Day can't be blank Day is not a number"
      end

      it "should add a valid visit group" do
        find('#add_visit_group_button').click()
        fill_in 'Visit Name', with: "visit name"
        fill_in 'Visit Day', with: 3
        click_button 'Add'
        expect(page).to have_content "Visit Created"
      end

      it "should add a visit group to the @service calendar" do
        visit_count = @arm1.visit_groups.count
        find('#add_visit_group_button').click()
        fill_in 'Visit Name', with: "visit name"
        fill_in 'Visit Day', with: 3
        bootstrap_select "#visit_group_position", "insert before #{@arm1.visit_groups.first.name}"
        click_button 'Add'
        wait_for_ajax
        expect(@arm1.visit_groups.count).to eq(visit_count + 1)
      end
    end

    describe "the remove visit group button" do

      it "should remove all but the last visit group" do
        visit_group = @arm3.visit_groups.first
        bootstrap_select "#visits", "#{visit_group.name}"
        find('#remove_visit_group_button').click()
        page.driver.browser.accept_js_confirms
        wait_for_ajax
        expect(page).to have_content "Arms must have at least one visit. Add another visit before deleting this one"
      end

      it "should remove the visit group from the service calendar" do
        create(:visit_group, arm: @arm3)
        @arm3.update_attributes(visit_count: 2)
        vg = @arm3.visit_groups.first
        bootstrap_select "#visits", "#{vg.name}"
        wait_for_ajax
        find('#remove_visit_group_button').click()
        page.driver.browser.accept_js_confirms
        wait_for_ajax
        expect(page).to have_content "Visit Destroyed"
      end
    end

    describe "the edit visit group button" do

      it "should update the visit group" do
        bootstrap_select "#visits", "#{@arm1.visit_groups.first.name}"
        find('#edit_visit_group_button').click()
        wait_for_ajax
        fill_in 'Visit Name', with: 'New Name'
        click_button 'Submit'
        wait_for_ajax
        expect(page).to have_content "New Name"
      end
    end
  end

  describe "services" do

    describe 'add modal' do
      it "should add @service to one or multiple arms" do
        expect(page).not_to have_css("div#arm_#{@arm1.id}_core_#{@service.sparc_core_id}")
        expect(page).not_to have_css("div#arm_#{@arm2.id}_core_#{@service.sparc_core_id}")
        find('#add_service_button').click()
        expect(page).to have_content "Add a Service"
        bootstrap_select "#service_id", @service.name
        find(:css,"#arm_ids_[value='#{@arm1.id} 1']").set(true)
        find(:css,"#arm_ids_[value='#{@arm2.id} 1']").set(true)
        click_button 'Add Service'
        expect(page).to have_content "Service(s) have been added to the chosen arms"
        expect(page).to have_css("div#arm_#{@arm1.id}_core_#{@service.sparc_core_id}")
        expect(page).to have_css("div#arm_#{@arm2.id}_core_#{@service.sparc_core_id}")
      end
    end

    describe 'remove modal' do

      before :each do
        li_1 = create(:line_item, arm: @arm1, service: @service, protocol: @protocol)
        li_2 = create(:line_item, arm: @arm2, service: @service, protocol: @protocol)
        visit current_path
      end

      it "should remove service from one or more arms" do
        expect(page).to have_css("div#arm_#{@arm1.id}_core_#{@service.sparc_core_id}")
        expect(page).to have_css("div#arm_#{@arm2.id}_core_#{@service.sparc_core_id}")
        find('#remove_service_button').click()
        expect(page).to have_content "Remove Services"
        bootstrap_select "#service_id", @service.name
        find(:css,"#arm_ids_[value='#{@arm1.id} 1']").set(true)
        find(:css,"#arm_ids_[value='#{@arm2.id} 1']").set(true)
        click_button 'Remove'
        expect(page).to have_content "Service(s) have been removed from the chosen arms"
        expect(page).not_to have_css("div#arm_#{@arm1.id}_core_#{@service.sparc_core_id}")
        expect(page).not_to have_css("div#arm_#{@arm2.id}_core_#{@service.sparc_core_id}")
      end

      it 'arm checkbox should only display if @service selected is on arm' do
        bootstrap_select "#services", @service.name
        wait_for_ajax
        find('#remove_service_button').click()
        assert_selector(".arm-checkbox > label", count: 2)
      end
    end
  end
end
