require 'rails_helper'

feature 'Visit group form validations', js: true do

  before(:each) do
    @protocol = create_and_assign_protocol_to_me
    @arm = @protocol.arms.first
    @visit_group = @arm.visit_groups.first
    visit protocol_path @protocol
  end

  context 'creating a visit group validates' do
    before(:each){ find("#add_visit_group_button").click }

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


  context 'editing a visit group validates' do
    before(:each){ find("#edit_visit_group_button").click }

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

  context 'removing a visit group validates' do
    before(:each){ find("#remove_visit_group_button").click }

    scenario 'there are no completed procedures' do
      when_there_is_a_completed_procedure
      then_they_should_see_an_error "Visit group '#{@visit_group.name}' has completed procedures and cannot be deleted"
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

  def when_there_is_a_completed_procedure
    participant  = create(:participant_with_appointments, protocol: @protocol, arm: @arm)
    procedure    = create(:procedure_complete, appointment: @visit_group.appointments.first, arm: @arm, completed_date: "10-09-2010")
    find("input[type='submit']").click
  end

  def then_they_should_see_an_error message
    expect(page).to have_content message
  end

end
