require "rails_helper"

feature "Task notifications", js: true do

  scenario "Identity sees that they have no Tasks" do
    given_i_have_no_tasks
    when_i_visit_the_home_page
    then_i_should_see_that_i_have_no_tasks
  end

  scenario "Identity sees that they have one assigned Task" do
    given_i_have_one_task
    when_i_visit_the_home_page
    then_i_should_see_that_i_have_one_task
  end

  scenario "Identity clicks on Tasks notification" do
    given_i_have_one_task
    when_i_visit_the_home_page
    when_i_click_on_the_task_notification
    then_i_should_be_on_the_tasks_page
    then_i_should_see_that_i_have_no_tasks
  end

  def given_i_have_no_tasks
    # Devise#sign_in
  end

  def given_i_have_one_task
    assignee = Identity.first
    assignor = create(:identity)

    create(:task, identity: assignor, assignee: assignee)
  end

  def when_i_visit_the_home_page
    visit tasks_path
    wait_for_ajax

    visit root_path
    wait_for_ajax
  end

  def when_i_click_on_the_task_notification
    find(".notification.task-notifications").click
  end

  def then_i_should_be_on_the_tasks_page
    expect(page).to have_css("body.tasks-index")
  end

  def then_i_should_see_that_i_have_no_tasks
    expect(page).to have_no_css(".notification.task-notifications", text: "0")
  end

  def then_i_should_see_that_i_have_one_task
    expect(page).to have_css(".notification.task-notifications", text: "1")
  end

  alias :and_i_visit_the_home_page :when_i_visit_the_home_page
end
