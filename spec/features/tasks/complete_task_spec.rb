require "rails_helper"

feature "Completing a Task", js: true do

  scenario "Identity sets a Task as complete" do
    given_i_have_an_assigned_task
    when_i_mark_the_task_as_complete
    then_i_should_not_see_the_task
  end

  def given_i_have_an_assigned_task
    assignee = Identity.first
    assignor = create(:identity)
    create_list(:task, 2, identity: assignor, assignee: assignee)

    visit tasks_path
    wait_for_ajax
  end

  def when_i_mark_the_task_as_complete
    first('input.complete').click
  end

  def then_i_should_not_see_the_task
    expect(page).to have_css("table.tasks tbody tr", count: 1)
  end
end
