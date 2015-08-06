require 'rails_helper'

feature 'Identity edits visit groups for a particular protocol', js: true do

  scenario "identity adds new visit group to an arm" do
    given_an_arm_with_visit_groups
    when_i_create_a_new_visit_group
    then_i_should_see_it_on_the_page
  end

  scenario "identity edits an exsisting visit group" do
    given_an_arm_with_visit_groups
    when_i_edit_a_visit_group
    then_i_should_see_the_changed_visit
  end

  scenario "identity tries to delete the last visit group on an arm" do
    given_an_arm_with_visit_groups
    when_i_remove_a_visit_group
    then_i_should_not_see_it_on_the_page
  end

  scenario "identity tries to delete only visit_group_on_an_arm" do
    given_an_arm_with_only_one_visit_group
    when_i_remove_a_visit_group
    then_i_should_still_see_it_on_the_page
  end

  def given_an_arm_with_visit_groups
    @protocol = create_and_assign_protocol_to_me
    @arm      = create(:arm_with_visit_groups, visit_count: 2, protocol: @protocol, subject_count: 3)
    visit protocol_path @protocol
  end

  def given_an_arm_with_only_one_visit_group
    @protocol = create_and_assign_protocol_to_me
    @arm      = create(:arm_with_one_visit_group, visit_count: 1, protocol: @protocol, subject_count: 3)
    visit protocol_path @protocol
  end

  def when_i_create_a_new_visit_group
    find("#add_visit_group_button").click
    wait_for_ajax
    bootstrap_select "#visit_group_arm_id", "#{@arm.name}"
    fill_in "visit_group_name", with: "VG"
    fill_in "visit_group_day", with: "4"
    find("input[type='submit']").click
  end

  def when_i_remove_a_visit_group
    find("#remove_visit_group_button").click
    find("input[type='submit']").click
    wait_for_ajax
  end

  def when_i_edit_a_visit_group
    find("#edit_visit_group_button").click
    fill_in "visit_group_name", with: "boredom"
    fill_in "visit_group_day", with: "80"
    find("input[type='submit']").click
  end

  def then_i_should_see_it_on_the_page
    expect(page).to have_content "Visit Created"
    wait_for_ajax
    expect(page).to have_css "input[value='VG']"
  end

  def then_i_should_still_see_it_on_the_page
    expect(page).to have_css "input[value='#{@arm.visit_groups.first.name}']"
  end

  def then_i_should_not_see_it_on_the_page
    expect(page).not_to have_css "input[value='#{@arm.visit_groups.first}']"
  end

  def then_i_should_see_the_changed_visit
    expect(page).to have_content "boredom"
  end

end
