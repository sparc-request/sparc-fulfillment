require 'rails_helper'

feature 'Visit group form validations', js: true do

  before(:each) do
    protocol = create_and_assign_protocol_to_me
    arm      = create(:arm_with_visit_groups, protocol: protocol)
    visit protocol_path protocol
    find("#add_visit_group_button").click
  end

  context 'creating a visit group validates' do

    scenario 'the presence of the name' do
      when_a_user_fails_to_enter_a_name
      then_they_should_see_an_error "Name can't be blank"
    end

    scenario 'the presence of the day' do
      when_a_user_fails_to_enter_a_day
      then_they_should_see_an_error "Day can't be blank"
    end

    scenario 'the numericality of the day' do
      when_a_user_enters_non_number_for_the_day
      then_they_should_see_an_error "Day is not a number"
    end
  end


  context 'editting a visit group validates' do

    scenario 'the presence of the name' do
      when_a_user_fails_to_enter_a_name
      then_they_should_see_an_error "Name can't be blank"
    end

    scenario 'the presence of the day' do
      when_a_user_fails_to_enter_a_day
      then_they_should_see_an_error "Day can't be blank"
    end

    scenario 'the numericality of the day' do
      when_a_user_enters_non_number_for_the_day
      then_they_should_see_an_error "Day is not a number"
    end

  end

  def when_a_user_fails_to_enter_a_name
    fill_in "visit_group_name", with: ""
    find("input[type='submit']").click
  end

  def when_a_user_fails_to_enter_a_day
    fill_in "visit_group_day", with: ""
    find("input[type='submit']").click
  end

  def when_a_user_enters_non_number_for_the_day
    fill_in "visit_group_day", with: "lol"
    find("input[type='submit']").click
  end

  def then_they_should_see_an_error message
    expect(page).to have_content message
  end

end
