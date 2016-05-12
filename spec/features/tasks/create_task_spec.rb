require "rails_helper"

feature "create Task", js: true do
  before :each do
    identity = Identity.first
    create(:protocol_imported_from_sparc)
    ClinicalProvider.create(organization: Organization.first, identity: identity)
    clinical_providers = ClinicalProvider.where(organization_id: identity.protocols.map{|p| p.sub_service_request.organization_id })
    @assignee = clinical_providers.first.identity
  end

  scenario 'Identity creates a multiple Tasks for themselves' do
    given_i_am_viewing_the_tasks_page
    when_i_create_a_task_assigned_to_myself
    then_i_should_see_the_task_is_assigned_to_me
    when_i_create_a_task_assigned_to_myself
    then_i_should_see_two_tasks_are_assigned_to_me
  end

  scenario 'Identity creates a new Task for another Identity' do
    given_i_am_viewing_the_tasks_page
    when_i_create_a_task_assigned_to_another_identity
    when_i_click_on_the_all_tasks_button
    then_i_should_see_the_task_is_assigned_to_the_identity
  end

  def given_i_am_viewing_the_tasks_page
    visit tasks_path
    wait_for_ajax
  end

  def when_i_create_a_task_assigned_to_myself
    find(".new-task").click
    bootstrap_select '#task_assignee_id', @assignee.full_name
    page.execute_script %Q{ $('#follow_up_datepicker').trigger("focus") }
    page.execute_script %Q{ $("td.day:contains('15')").trigger("click") }
    fill_in :task_body, with: "Test body"
    click_button 'Save'
    wait_for_ajax
  end

  def when_i_create_a_task_assigned_to_another_identity
    find(".new-task").click
    bootstrap_select '#task_assignee_id', @assignee.full_name
    page.execute_script %Q{ $('#follow_up_datepicker').trigger("focus") }
    page.execute_script %Q{ $("td.day:contains('15')").trigger("click") }
    fill_in :task_body, with: "Test body"
    click_button 'Save'
    wait_for_ajax
  end

  def when_i_click_on_the_all_tasks_button
    find('#all_tasks').click
    wait_for_ajax
  end

  def then_i_should_see_the_task_is_assigned_to_me
    expect(page).to have_css("table.tasks tbody tr", count: 1)
    expect(page).to have_css(".notification.task-notifications", text: 1)
  end

  def then_i_should_see_two_tasks_are_assigned_to_me
    expect(page).to have_css("table.tasks tbody tr", count: 2)
    expect(page).to have_css(".notification.task-notifications", text: 2)
  end

  def then_i_should_see_the_task_is_assigned_to_the_identity
    expect(page).to have_css("table.tasks tbody td.assignee_name", count: 1, text: @assignee.full_name)
  end
end
