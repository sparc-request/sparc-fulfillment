require "rails_helper"

feature "Task list", js: true do

  scenario "User with no Tasks views Tasks list" do
    as_a_user_with_no_tasks
    when_i_visit_the_tasks_page
    then_i_should_see_that_i_have_no_tasks
  end

  scenario "User with Tasks present views Tasks list" do
    as_a_user_with_tasks
    when_i_visit_the_tasks_page
    then_i_should_see_that_i_have_tasks
  end

  def as_a_user_with_tasks
    @user = User.first

    create_list(:task, 2, user: @user)
  end

  def as_a_user_with_no_tasks
    # Devise#sign_in
  end

  def when_i_visit_the_tasks_page
    visit tasks_path
  end

  def then_i_should_see_that_i_have_no_tasks
    expect(page).to have_css("table.tasks", text: "No matching records found")
  end

  def then_i_should_see_that_i_have_tasks
    expect(page).to have_css("table.tasks tbody td.user_name", text: @user.full_name)
  end
end
