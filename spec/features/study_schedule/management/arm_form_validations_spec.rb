require 'rails_helper'

feature 'Arm form validations', js: true do

  context "editing an arm" do

    before(:each) do
      protocol = create_and_assign_protocol_to_me
      visit protocol_path protocol
      find("#edit_arm_button").click
    end

    scenario "name validation" do
      user_fails_to_fill_out_name
      then_sees_an_error_on_submission "Name can't be blank"
    end

    scenario "subject count validation" do
      user_fails_to_fill_out_subject_count
      then_sees_an_error_on_submission "Subject count is not a number"
    end
  end

  context "adding an arm" do

    before(:each) do
      protocol = create_and_assign_protocol_to_me
      visit protocol_path protocol
      find("#add_arm_button").click
    end

    scenario "name validation" do
      user_fails_to_fill_out_name
      then_sees_an_error_on_submission "Name can't be blank"
    end

    scenario "subject count validation" do
      user_fails_to_fill_out_subject_count
      then_sees_an_error_on_submission "Subject count is not a number"
    end

    scenario "visit count validation" do
      user_fails_to_fill_out_visit_count
      then_sees_an_error_on_submission "Visit count is not a number"
    end
  end

  def user_fails_to_fill_out_name
    fill_in "arm_name", with: ""
    submit
  end

  def user_fails_to_fill_out_subject_count
    fill_in "arm_subject_count", with: ""
    submit
  end

  def user_fails_to_fill_out_visit_count
    fill_in "arm_visit_count", with: ""
    submit
  end

  def submit
    find("input[type='submit']").click
  end

  def then_sees_an_error_on_submission message
    wait_for_ajax
    expect(page).to have_content message
  end

end
