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

RSpec.describe "Identity views Task", type: :system, js: true do
  let(:identity) { @logged_in_identity }
  let(:protocol) { create(:protocol_imported_from_sparc) }
  
  # Cleanly structure the Organization core requirement
  let(:core) do
    org = protocol.sub_service_request.organization
    org.update(type: "Core", parent_id: create(:organization_program).id)
    org
  end
  let(:provider) { create(:clinical_provider, organization: core, identity: identity) }

  # Scenario 1 State: Identity Task
  let(:identity_task) do
    create(:task, identity: identity, assignee: identity, assignable: identity, body: "Identity Task Body")
  end

  # Scenario 2 State: Procedure Task
  let(:procedure) do
    # Safely grabbing the associated records created implicitly by the protocol factory to maintain referential integrity
    appt = Appointment.first || create(:appointment)
    visit_obj = Visit.first || create(:visit)
    create(:procedure, appointment: appt, visit: visit_obj, sparc_core_id: core.id)
  end
  let(:procedure_task) do
    create(:task, identity: identity, assignee: identity, assignable: procedure, body: "Procedure Task Body")
  end

  it "views an Identity Task assigned to themselves" do
    given_i_have_an_identity_task
    when_i_view_the_task("Identity Task Body")
    then_i_should_see_the_identity_task_details
  end

  it "views a Procedure Task they assigned to themselves" do
    given_i_have_a_procedure_task
    when_i_view_the_task("Procedure Task Body")
    then_i_should_see_the_procedure_task_details
  end

  def given_i_have_an_identity_task
    provider
    identity_task
  end

  def given_i_have_a_procedure_task
    provider
    procedure_task
  end

  def when_i_view_the_task(task_body)
    visit tasks_path
    
    expect(page).to have_css("table.tasks tbody tr", text: task_body, visible: true)
    
    find("table.tasks tbody tr", text: task_body).click
    
    expect(page).to have_css(".modal-content", visible: true)
  end

  def then_i_should_see_the_identity_task_details
    within('.modal-content') do
      expect(page).to have_css("div", text: /Created by/i)
      expect(page).to have_css("div", text: /Assigned to/i)
      expect(page).to have_css("div", text: /Type/i)
      expect(page).to have_css("div", text: /Task/i)
      expect(page).to have_css("div", text: /Due At/i)
      expect(page).to have_css("div", text: /Completed/i)
    end
  end

  def then_i_should_see_the_procedure_task_details
    # A Procedure Task should contain all the Identity details...
    then_i_should_see_the_identity_task_details

    # ...plus these specific clinical details
    within('.modal-content') do
      expect(page).to have_css("div", text: /Participant Name/i)
      expect(page).to have_css("div", text: /Protocol/i)
      expect(page).to have_css("div", text: /Visit/i)
      expect(page).to have_css("div", text: /Arm/i)
    end
  end
end
