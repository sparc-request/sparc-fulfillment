# Copyright © 2011-2018 MUSC Foundation for Research Development~
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
    wait_for_ajax
  end

  def when_i_view_a_identity_task_assigned_to_myself
    assignee = Identity.first

    find(".new-task").click
    bootstrap_select '#task_assignee_id', @assignee.full_name
    bootstrap_datepicker '#follow_up_datepicker', day: '15'
    fill_in :task_body, with: "Test body"
    find("#new_task .modal-footer .btn-primary").click
    wait_for_ajax
    find("table.tasks tbody tr:first-child").click
    wait_for_ajax
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
    expect(page).to have_css(".modal dt", text: "Due Date")
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
