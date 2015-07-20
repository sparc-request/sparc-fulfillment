require 'rails_helper'

feature 'Identity edits visit groups for a particular protocol', js: true do

  scenario "identity adds new visit group to an arm" do
    given_an_arm_with_visit_groups
    when_i_create_a_new_visit_group
    then_i_should_see_it_on_the_page
  end

  scenario "identity edits an exsisting visit group" do
  end

  scenario "identity tries to delete the last visit group on an arm" do
  end

  def given_an_arm_with_visit_groups
    @protocol = create_and_assign_protocol_to_me
    @arm      = create(:arm, visit_count: 2, protocol: @protocol, subject_count: 3)
    visit protocol_path @protocol
  end

  def given_an_arm_with_only_one_visit_group
    @protocol = create_and_assign_protocol_to_me
    @arm      = create(:arm, visit_count: 1, protocol: @protocol, subject_count: 3)
    visit protocol_path @protocol
  end

  def when_i_create_a_new_visit_group
    select "#{@arm.name}", from: "visit_group_name"
    find("#add_visit_group_button").click
    fill_in "visit_group_name", with: "VG"
    fill_in "visit_group_day", with: "4"
    find("input[type='submit']").click
  end

  def when_i_remove_a_visit_group

  end

  def when_i_edit_a_visit_group
  end

  def then_i_should_see_it_on_the_page
    expect(page).to have_content "Visit Created"
    wait_for_ajax
    screenshot
    expect(page).to have_css "input[value='VG']"
  end


end
