require "rails_helper"

feature "View Tasks", js: true do

  scenario "User with no Tasks views Tasks list" do
    as_a_user_with_no_tasks
    when_i_visit_the_tasks_page
    then_i_should_see_that_i_have_no_tasks
  end

  scenario "User views complete Tasks" do
    as_a_user_with_complete_tasks
    when_i_view_complete_tasks
    then_i_should_see_complete_tasks
  end

  scenario "User views only their Tasks" do
    given_i_have_assigned_tasks
    when_i_visit_the_tasks_page
    then_i_should_only_see_tasks_assigned_to_me
  end

  scenario "User initially views only incomplete Tasks" do
    given_i_have_complete_and_incomplete_tasks
    when_i_visit_the_tasks_page
    then_i_should_see_only_incomplete_tasks
  end

  def as_a_user_with_incomplete_tasks
    @user = User.first

    create_list(:task, 2, user: @user)
  end

  def as_a_user_with_complete_tasks
    @user = User.first

    create_list(:task_complete, 2, user: @user)
  end

  def given_i_have_assigned_tasks
    as_a_user_with_incomplete_tasks

    other_user = create(:user)
    create_list(:task, 2, user: other_user, assignee: other_user)
  end

  def given_i_have_complete_and_incomplete_tasks
    as_a_user_with_incomplete_tasks
    as_a_user_with_complete_tasks
  end

  def as_a_user_with_complete_tasks
    user = User.first

    user.tasks.push build(:task_complete, assignee_id: user.id)
  end

  def as_a_user_with_no_tasks
    # Devise#sign_in
  end

  def when_i_view_complete_tasks
    when_i_visit_the_tasks_page
    find("button.complete").click
  end

  def when_i_visit_the_tasks_page
    visit tasks_path
  end

  def then_i_should_see_that_i_have_no_tasks
    expect(page).to have_css("table.tasks", text: "No matching records found")
  end

  def then_i_should_see_complete_tasks
    expect(page).to have_css("table.tasks input[checked]")
  end

  def then_i_should_only_see_tasks_assigned_to_me
    expect(page).to have_css("table.tasks tbody tr", count: 2)
  end

  def then_i_should_see_only_incomplete_tasks
    expect(page).to_not have_css("table.tasks tbody input[checked]")
  end
end
