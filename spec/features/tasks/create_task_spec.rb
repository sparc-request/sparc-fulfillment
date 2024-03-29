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

feature "create Task", js: true do
  before :each do
    DatabaseCleaner[:active_record, model: Task].clean_with(:truncation)
    @assignee = Identity.first
    @second_assignee = create(:identity)
    protocol = create(:protocol_imported_from_sparc)
    ClinicalProvider.create(organization: protocol.sub_service_request.organization, identity: @assignee)
    ClinicalProvider.create(organization: protocol.sub_service_request.organization, identity: @second_assignee)
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
    wait_for_ajax
    when_i_click_on_the_all_tasks_button
    then_i_should_see_the_task_is_assigned_to_the_identity
  end

  def given_i_am_viewing_the_tasks_page
    visit tasks_path
    wait_for_ajax
  end

  def when_i_create_a_task_assigned_to_myself
    find("a.btn.btn-success").click
    bootstrap_select '#task_assignee_id', @assignee.full_name
    bootstrap_datepicker '.datetimepicker-input', day: '15'
    fill_in :task_body, with: "Test body"
    find("#new_task .modal-footer .btn-primary").click
    wait_for_ajax
  end

  def when_i_create_a_task_assigned_to_another_identity
    find("a.btn.btn-success").click
    bootstrap_select '#task_assignee_id', @second_assignee.full_name
    bootstrap_datepicker '.datetimepicker-input', day: '15'
    fill_in :task_body, with: "Test body"
    find("#new_task .modal-footer .btn-primary").click
    wait_for_ajax
  end

  def when_i_click_on_the_all_tasks_button
    find("#allTasksToggle", visible: false).find(:xpath, "..").click
    wait_for_ajax
  end

  def then_i_should_see_the_task_is_assigned_to_me
    expect(page).to have_css("table.tasks tbody tr", count: 1)
    expect(page).to have_css("span.badge", text: 1)
  end

  def then_i_should_see_two_tasks_are_assigned_to_me
    expect(page).to have_css("table.tasks tbody tr", count: 2)
    expect(page).to have_css("span.badge", text: 2)
  end

  def then_i_should_see_the_task_is_assigned_to_the_identity
    expect(page).to have_css("table.tasks tbody td:nth-child(2)", count: 1, text: @second_assignee.full_name)
  end
end
