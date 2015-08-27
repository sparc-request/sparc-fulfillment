require 'rails_helper'

feature 'Identity edits visit groups for a particular protocol', js: true do

  context "User adds a visit group to an arm" do
    context "and fills the form out correctly" do
      scenario "and sees the visit group on the arm" do
        given_i_am_viewing_an_arm_with_multiple_visit_groups
        when_i_click_the_add_visit_group_button
        when_i_fill_in_the_form
        when_i_click_the_add_submit_button
        then_i_should_see_the_visit_group
      end

      scenario "and sees a flash notification" do
        given_i_am_viewing_an_arm_with_multiple_visit_groups
        when_i_click_the_add_visit_group_button
        when_i_fill_in_the_form
        when_i_click_the_add_submit_button
        then_i_should_see_a_flash_message_of_type 'add'
      end

      scenario "and sees it in the correct position" do
        given_i_am_viewing_an_arm_with_multiple_visit_groups

        @original_visit_group_1 = @arm.visit_groups.first
        @original_visit_group_2 = @arm.visit_groups.second
        
        when_i_click_the_add_visit_group_button
        when_i_fill_in_the_form
        when_i_set_the_position_to "insert before #{@arm.visit_groups.second.name}"
        when_i_click_the_add_submit_button
        then_i_should_see_the_position_is 1
      end
    end

    context "and fills the form out incorrectly" do
      scenario "and sees some errors" do
        given_i_am_viewing_an_arm_with_multiple_visit_groups
        when_i_click_the_add_visit_group_button
        when_i_click_the_add_submit_button
        then_i_should_see_errors_of_type 'add'
      end
    end
  end

  context "User edits a visit group on an arm" do
    context "and fills the form out correctly" do
      scenario "and sees the updated arm" do
        given_i_am_viewing_an_arm_with_multiple_visit_groups
        when_i_click_the_edit_visit_group_button
        when_i_set_the_name_to 'VG 2'
        when_i_set_the_day_to 44
        when_i_click_the_save_submit_button
        then_i_should_see_the_updated_visit_group
      end

      scenario "and sees a flash message" do
        given_i_am_viewing_an_arm_with_multiple_visit_groups
        when_i_click_the_edit_visit_group_button
        when_i_click_the_save_submit_button
        then_i_should_see_a_flash_message_of_type 'edit'
      end
    end

    context "and fills the form out incorrectly" do
      scenario "and sees some errors" do
        given_i_am_viewing_an_arm_with_multiple_visit_groups
        when_i_click_the_edit_visit_group_button
        when_i_set_the_name_to nil
        when_i_set_the_day_to nil
        when_i_click_the_save_submit_button
        then_i_should_see_errors_of_type 'edit'
      end
    end
  end

  context "User edits a visit groups name in the service calendar" do
    context "and provides a name" do
      scenario "and sees the updated name" do
        given_i_am_viewing_an_arm_with_one_visit_group
        when_i_enter_the_name "VG YO"
        then_i_should_see_the_name "VG YO"
      end
    end

    context "and leaves the name blank" do
      scenario "and sees the original name" do
        given_i_am_viewing_an_arm_with_one_visit_group
        @original_name = @arm.visit_groups.first.name
        
        when_i_enter_the_name ""
        then_i_should_see_the_original_name
      end
    end
  end

  context "User deletes a visit group from an arm" do
    scenario "and does not see the visit group on the arm" do
      given_i_am_viewing_an_arm_with_multiple_visit_groups
      when_i_click_the_remove_visit_group_button
      when_i_click_the_remove_submit_button
      then_i_should_not_see_the_visit_group
    end

    scenario "and sees a flash message" do
      given_i_am_viewing_an_arm_with_multiple_visit_groups
      when_i_click_the_remove_visit_group_button
      when_i_click_the_remove_submit_button
      then_i_should_see_a_flash_message_of_type 'remove'
    end
  end

  context "User tries to delete the last visit group on an arm" do
    scenario "and sees some errors" do
      given_i_am_viewing_an_arm_with_one_visit_group
      when_i_click_the_remove_visit_group_button
      when_i_click_the_remove_submit_button
      then_i_should_see_errors_of_type 'last vg'
    end
  end

  def given_i_am_viewing_an_arm_with_multiple_visit_groups
    @protocol = create_and_assign_protocol_to_me
    @protocol.arms.each do |arm|
      arm.delete
    end
    @arm      = create(:arm_with_visit_groups, visit_count: 2, protocol: @protocol, subject_count: 3)
    @visit_groups = @arm.visit_groups
    visit protocol_path @protocol
  end

  def given_i_am_viewing_an_arm_with_one_visit_group
    @protocol = create_and_assign_protocol_to_me
    @protocol.arms.each do |arm|
      arm.delete
    end
    @arm      = create(:arm_with_one_visit_group, visit_count: 1, protocol: @protocol, subject_count: 3)
    visit protocol_path @protocol
  end

  def when_i_click_the_add_visit_group_button
    find("#add_visit_group_button").click
  end

  def when_i_click_the_edit_visit_group_button
    find("#edit_visit_group_button").click
  end

  def when_i_click_the_remove_visit_group_button
    find("#remove_visit_group_button").click
  end

  def when_i_fill_in_the_form
    bootstrap_select "#visit_group_arm_id", "#{@arm.name}"
    fill_in "visit_group_name", with: "VG"
    fill_in "visit_group_day", with: "4"
    wait_for_ajax
  end

  def when_i_set_the_name_to name
    fill_in "visit_group_name", with: name
  end

  def when_i_set_the_day_to day
    fill_in "visit_group_day", with: day
  end

  def when_i_click_the_add_submit_button
    click_button 'Add'
    wait_for_ajax
  end

  def when_i_click_the_remove_submit_button
    click_button 'Remove'
    wait_for_ajax
  end

  def when_i_click_the_save_submit_button
    click_button "Save"
    wait_for_ajax
  end

  def when_i_set_the_position_to position_identifier
    bootstrap_select "#visit_group_position", position_identifier
  end

  def when_i_enter_the_name name
    fill_in "visit_group_#{@arm.visit_groups.first.id}", with: name
    wait_for_ajax

    first(".study_schedule_table_name").click
    wait_for_ajax
  end

  def then_i_should_see_the_visit_group
    wait_for_ajax
    expect(page).to have_css("input[value='VG']")
  end

  def then_i_should_see_the_updated_visit_group
    vg_id = @arm.visit_groups.first.id
    expect(find("#visit_group_#{vg_id}").value).to eq("VG 2")
  end

  def then_i_should_not_see_the_visit_group
    expect(page).to_not have_content("#{@visit_groups.first.name}")
  end

  def then_i_should_see_the_position_is position
    @new_visit_group = @arm.visit_groups.find_by_name("VG")

    within(".visit_groups_for_#{@arm.id}") do
      expect(page.all(".visit_name")[0].value).to eq(@original_visit_group_1.name)
      expect(page.all(".visit_name")[1].value).to eq(@new_visit_group.name)
      expect(page.all(".visit_name")[2].value).to eq(@original_visit_group_2.name)
    end
  end

  def then_i_should_see_the_name name
    expect(find("#visit_group_#{@arm.visit_groups.first.id}").value).to eq(name)
  end

  def then_i_should_see_the_original_name
    expect(find("#visit_group_#{@arm.visit_groups.first.id}").value).to eq(@original_name)
  end

  def then_i_should_see_errors_of_type action_type
    case action_type
      when 'add'
        expect(page).to have_content("Name can't be blank")
        expect(page).to have_content("Day can't be blank")
        expect(page).to have_content("Day is not a number")
      when 'edit'
        expect(page).to have_content("Name can't be blank")
        expect(page).to have_content("Day can't be blank")
        expect(page).to have_content("Day is not a number")

      when 'last vg'
        expect(page).to have_content("Arm must have at least one visit. Add another visit before deleting this one")
    end
  end

  def then_i_should_see_a_flash_message_of_type action_type
    case action_type
      when 'add'
        expect(page).to have_content("Visit Created")
      when 'edit'
        expect(page).to have_content("Visit Updated")
      when 'remove'
        expect(page).to have_content("Visit Destroyed")
    end
  end
end
