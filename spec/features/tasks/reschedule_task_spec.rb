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
    wait_for_ajax
  end

  def when_i_reschedule_the_task
    page.all('.task-reschedule').last.click
    wait_for_ajax
    
    page.execute_script %Q{ $('#reschedule_datepicker').trigger("focus") }
    page.execute_script %Q{ $("td.day:contains('15')").trigger("click") }
    wait_for_ajax
    
    click_button "Save"
    wait_for_ajax
  end

  def then_i_should_see_the_task_has_been_rescheduled
    expect(page).to have_css("table.tasks tbody td.due_at", text: "09/15/2025")
    expect(page).to have_css("tr[data-index='0'] td.due_at", text: "09/09/2025")
  end
end
