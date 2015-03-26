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

  def then_i_should_see_that_i_have_no_tasks
    expect(page).to have_css(".notification.tasks", text: "0")
  end

  def then_i_should_see_that_i_have_one_task
    expect(page).to have_css(".notification.tasks", text: "1")
  end
end
