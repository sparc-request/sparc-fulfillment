require "rails_helper"

feature "Identity views Task", js: true do
  before :each do
    identity = Identity.first
    create(:protocol_imported_from_sparc)
    @core = Organization.where(type: "Core").first
    @program = create(:organization_program)
    @core.update_attributes(parent_id: @program.id)
    ClinicalProvider.create(organization: Organization.first, identity: identity)
    clinical_providers = ClinicalProvider.where(organization_id: identity.protocols.map{|p| p.sub_service_request.organization_id })
    @assignee = clinical_providers.first.identity
  end

  scenario "Identity views a Task that have assigned to themselves" do
    given_i_am_on_the_tasks_page
    when_i_view_a_identity_task_assigned_to_myself
    then_i_should_see_the_identity_task_details
  end

  scenario "Identity views a Procedure Task they assigned to themselves" do
    given_i_have_been_assigned_a_procedure_task
    when_i_view_the_procedure_task_assigned_to_myself
    then_i_should_see_the_procedure_task_details
  end

  def given_i_am_on_the_tasks_page
    visit tasks_path
  end

  def when_i_view_a_identity_task_assigned_to_myself
    assignee = Identity.first

    find(".new-task").click
    bootstrap_select '#task_assignee_id', @assignee.full_name
    page.execute_script %Q{ $('#task_due_at').siblings(".input-group-addon").trigger("click") }
    page.execute_script %Q{ $("td.day:contains('15')").trigger("click") }
    fill_in :task_body, with: "Test body"
    click_button 'Save'
    find("table.tasks tbody tr:first-child").click
  end

  def given_i_have_been_assigned_a_procedure_task
    create(:protocol_imported_from_sparc)
    identity        = Identity.first
    appointment = Appointment.first
    visit       = Visit.first
    procedure   = create(:procedure, appointment: appointment, visit: visit, sparc_core_id: @core.id)

    procedure.tasks.push build(:task, identity: identity, assignee: identity)
  end

  def when_i_view_the_procedure_task_assigned_to_myself
    given_i_am_on_the_tasks_page
    find("table.tasks tbody tr:first-child").click
  end

  def then_i_should_see_the_identity_task_details
    expect(page).to have_css(".modal dt", text: "Created by")
    expect(page).to have_css(".modal dt", text: "Assigned to")
    expect(page).to have_css(".modal dt", text: "Type")
    expect(page).to have_css(".modal dt", text: "Task")
    expect(page).to have_css(".modal dt", text: "Due date")
    expect(page).to have_css(".modal dt", text: "Completed")
  end

  def then_i_should_see_the_procedure_task_details
    then_i_should_see_the_identity_task_details
    expect(page).to have_css(".modal dt", text: "Participant Name")
    expect(page).to have_css(".modal dt", text: "Protocol")
    expect(page).to have_css(".modal dt", text: "Visit")
    expect(page).to have_css(".modal dt", text: "Arm")
  end
end
