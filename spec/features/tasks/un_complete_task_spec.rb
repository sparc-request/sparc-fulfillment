require "rails_helper"

feature "un-completing a Task", js: true do

  scenario "User sets a completed Task to incomplete" do
    given_i_have_set_a_task_to_complete
    when_i_set_the_task_to_incomplete
    then_i_should_see_that_the_task_is_incomplete
  end

  def given_i_have_set_a_task_to_complete
    assignee = User.first
    assignor = create(:user)
    create_list(:task, 2, user: assignor, assignee: assignee)

    visit tasks_path
    first('input.complete').click
    wait_for_ajax
    expect(page).to have_css("table.tasks tbody tr", count: 1)
  end

  def when_i_set_the_task_to_incomplete
    find("#complete").click
    wait_for_ajax
    first('input.complete').click
  end

  def then_i_should_see_that_the_task_is_incomplete
    expect(page).to have_css("table.tasks tbody tr", count: 2)
  end
end
