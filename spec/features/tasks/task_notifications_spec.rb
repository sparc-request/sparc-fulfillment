require "rails_helper"

feature "Task notifications", js: true do

  scenario "User sees that they have no Tasks" do
    as_a_user_who_has_no_tasks
    when_i_visit_the_home_page
    then_i_should_see_that_i_have_no_tasks
  end

  scenario "User sees that they have one assigned Task" do
    as_a_user_who_has_one_task
    when_i_visit_the_home_page
    then_i_should_see_that_i_have_one_task
  end

  scenario "User clicks on Tasks notification" do
    as_a_user_who_has_one_task
    and_i_visit_the_home_page
    when_i_click_on_the_task_notification
    then_i_should_be_on_the_tasks_page
  end

  def as_a_user_who_has_no_tasks
    # Devise#sign_in
  end

  def as_a_user_who_has_one_task
    assignee = User.first
    assignor = create(:user)

    create(:task, user: assignor, assignee: assignee)
  end

  def when_i_visit_the_home_page
    visit tasks_path
    visit root_path
  end

  def when_i_click_on_the_task_notification
    find(".notification").click
  end

  def then_i_should_be_on_the_tasks_page
    expect(page).to have_css("body.tasks-index")
  end

  def then_i_should_see_that_i_have_no_tasks
    expect(page).to have_css(".notification.task-notifications", text: "0")
  end

  def then_i_should_see_that_i_have_one_task
    expect(page).to have_css(".notification.task-notifications", text: "1")
  end

  alias :and_i_visit_the_home_page :when_i_visit_the_home_page
end
