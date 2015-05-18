require "rails_helper"

feature "create Task", js: true do

  scenario 'Identity creates a new Task for themselves' do
    as_a_identity_who_is_on_the_tasks_page
    when_i_create_a_task_assigned_to_myself
    then_i_should_see_the_task_is_assigned_to_me
  end

  scenario 'Identity creates a new Task for another Identity' do
    as_a_identity_who_is_on_the_tasks_page
    when_i_create_a_task_assigned_to_another_identity
    then_i_should_see_the_task_is_assigned_to_the_identity
  end

  def as_a_identity_who_is_on_the_tasks_page
    visit tasks_path
    visit tasks_path
  end

  def when_i_create_a_task_assigned_to_myself
    assignee = Identity.first

    click_link "Create New Task"
    select assignee.full_name, from: 'task_assignee_id'
    page.execute_script %Q{ $('#task_due_at').trigger("focus") }
    page.execute_script %Q{ $("td.day:contains('15')").trigger("click") }
    fill_in :task_body, with: "Test body"
    click_button 'Save'
  end

  def when_i_create_a_task_assigned_to_another_identity
    @assignee = create(:identity)

    click_link "Create New Task"
    select @assignee.full_name, from: 'task_assignee_id'
    page.execute_script %Q{ $('#task_due_at').trigger("focus") }
    page.execute_script %Q{ $("td.day:contains('15')").trigger("click") }
    fill_in :task_body, with: "Test body"
    click_button 'Save'
  end

  def then_i_should_see_the_task_is_assigned_to_me
    expect(page).to have_css("table.tasks tbody tr", count: 1)
    expect(page).to have_css(".notification.task-notifications", text: 1)
  end

  def then_i_should_see_the_task_is_assigned_to_the_identity
    expect(page).to have_css("table.tasks tbody td.assignee_name", count: 1, text: @assignee.full_name)
  end
end
