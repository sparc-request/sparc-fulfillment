require "rails_helper"

feature "rescheduling a Task", js: true do

  scenario "User reschedules a Task" do
    as_a_user_who_has_assigned_a_task
    when_i_reschedule_the_task
    then_i_should_see_the_task_has_been_rescheduled
  end

  def as_a_user_who_has_assigned_a_task
    @user = User.first
    create_list(:task, 2, user: @user)
    @task = Task.first

    visit tasks_path
  end

  def when_i_reschedule_the_task
    @next_month = (Time.current + 1.month).strftime('%F')

    page.all('.task-reschedule').last.click
    fill_in "task_due_at", with: @next_month
    click_button "Save"
  end

  def then_i_should_see_the_task_has_been_rescheduled
    expect(page).to have_css("table.tasks tbody td.due_at", text: @next_month)
    expect(page).to have_css("tr[data-index='0'] td.due_at", text: @next_month)
  end
end
