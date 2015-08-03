require "rails_helper"

feature "rescheduling a Task", js: true do

  scenario "Identity reschedules a Task" do
    given_i_have_an_assigned_a_task
    when_i_reschedule_the_task
    then_i_should_see_the_task_has_been_rescheduled
  end

  def given_i_have_an_assigned_a_task
    @identity = Identity.first
    create_list(:task, 2, identity: @identity, assignee: @identity)
    @task = Task.first

    visit tasks_path
  end

  def when_i_reschedule_the_task
    wait_for_ajax
    @next_month = (Time.current + 1.month).strftime('%m/%d/%y')
    page.all('.task-reschedule').last.click
    wait_for_ajax
    
    fill_in "task_due_at", with: @next_month
    wait_for_ajax
    
    click_button "Save"
    wait_for_ajax
  end

  def then_i_should_see_the_task_has_been_rescheduled
    expect(page).to have_css("table.tasks tbody td.due_at", text: @day)
    expect(page).to have_css("tr[data-index='0'] td.due_at", text: @day)
  end
end
