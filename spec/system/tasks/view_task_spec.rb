# Copyright © 2011-2023 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

require "rails_helper"

feature "Identity views Task", js: true do
  before :each do
    DatabaseCleaner[:active_record, db: Task].clean_with(:truncation)
    
    @assignee = Identity.first
    protocol = create(:protocol_imported_from_sparc)
    @core = Organization.where(type: "Core").first
    @program = create(:organization_program)
    @core.update(parent_id: @program.id)
    ClinicalProvider.create(organization: protocol.sub_service_request.organization, identity: @assignee)
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

    expect(page).to have_css("table.tasks", wait: 5)
  end

  def when_i_view_a_identity_task_assigned_to_myself
    new_task_btn = find_link("Create New Task", wait: 5)
    new_task_btn.hover
    new_task_btn.click

    expect(page).to have_css('#new_task', wait: 5)

    bootstrap_select '#task_assignee_id', @assignee.full_name
    bootstrap_datepicker '.datetimepicker-input', day: '15'
    fill_in :task_body, with: "Test body"

    submit_btn = find("#new_task .modal-footer .btn-primary", wait: 5)
    submit_btn.hover
    submit_btn.click

    expect(page).to_not have_css('#new_task', wait: 5)

    task = Task.where(body: "Test body").last
    task.update_columns(assignable_type: "Identity", assignable_id: @assignee.id)

    page.execute_script("$('table.tasks').bootstrapTable('refresh')")

    # Sync Point & Geckodriver Fix: Wait for the new row, then physically target its first cell
    target_row = find("table.tasks tbody tr", text: "Test body", wait: 5)
    target_cell = target_row.first("td")
    target_cell.hover
    target_cell.click

    expect(page).to have_css(".modal div", text: "Created by", wait: 5)
  end

  def given_i_have_been_assigned_a_procedure_task
    create(:protocol_imported_from_sparc)
    identity    = Identity.first
    appointment = Appointment.first
    visit       = Visit.first
    procedure   = create(:procedure, appointment: appointment, visit: visit, sparc_core_id: @core.id)

    procedure.tasks.push build(:task, identity: identity, assignee: identity)
  end

  def when_i_view_the_procedure_task_assigned_to_myself
    given_i_am_on_the_tasks_page
    
    target_cell = first("table.tasks tbody tr:first-child td", wait: 5)
    target_cell.hover
    target_cell.click
    
    expect(page).to have_css(".modal div", text: "Created by", wait: 5)
  end

  def then_i_should_see_the_identity_task_details
    expect(page).to have_css(".modal div", text: "Created by", wait: 5)
    expect(page).to have_css(".modal div", text: "Assigned to", wait: 5)
    expect(page).to have_css(".modal div", text: "Type", wait: 5)
    expect(page).to have_css(".modal div", text: "Task", wait: 5)
    expect(page).to have_css(".modal div", text: "Due At", wait: 5)
    expect(page).to have_css(".modal div", text: "Completed", wait: 5)
  end

  def then_i_should_see_the_procedure_task_details
    then_i_should_see_the_identity_task_details

    expect(page).to have_css(".modal div", text: "Participant Name", wait: 5)
    expect(page).to have_css(".modal div", text: "Protocol", wait: 5)
    expect(page).to have_css(".modal div", text: "Visit", wait: 5)
    expect(page).to have_css(".modal div", text: "Arm", wait: 5)
  end
end
