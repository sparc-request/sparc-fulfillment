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

RSpec.describe "Create Task", type: :system, js: true do
  let(:identity)        { @logged_in_identity }
  let(:second_assignee) { create(:identity) }
  let(:protocol)        { create(:protocol_imported_from_sparc) }
  
  let(:target_date)     { Date.today.next_month.change(day: 15) }

  it 'creates multiple Tasks for themselves' do
    given_i_am_viewing_the_tasks_page
    when_i_create_a_task_assigned_to(identity)
    then_i_should_see_tasks_assigned_to_me_count(1)
    
    when_i_create_a_task_assigned_to(identity)
    then_i_should_see_tasks_assigned_to_me_count(2)
  end

  it 'creates a new Task for another Identity' do
    given_i_am_viewing_the_tasks_page
    when_i_create_a_task_assigned_to(second_assignee)
    when_i_click_on_the_all_tasks_button
    then_i_should_see_the_task_is_assigned_to_the_identity(second_assignee)
  end

  def given_i_am_viewing_the_tasks_page
    org = protocol.sub_service_request.organization
    create(:clinical_provider, organization: org, identity: identity)
    create(:clinical_provider, organization: org, identity: second_assignee)

    visit tasks_path
    
    expect(page).to have_css('a.btn.btn-success', visible: true)
  end

  def when_i_create_a_task_assigned_to(assignee)
    find("a.btn.btn-success").click
    
    expect(page).to have_css('#new_task', visible: true)
    
    formatted_date = target_date.strftime('%m/%d/%Y')
    
    # Executed outside the `within` block because Bootstrap select menus append to the <body>
    bootstrap_select '#task_assignee_id', assignee.full_name
    
    within('#new_task') do
      # Safely type and blur inside the modal until the JS accepts the value.
      while find('.datetimepicker-input').value != formatted_date
        find('.datetimepicker-input').set(formatted_date)
        # Safely blur by clicking the modal title rather than the page backdrop
        find('.modal-title').click 
      end

      fill_in 'task_body', with: "Test body"
      find(".modal-footer .btn-primary").click
    end
    
    expect(page).to have_no_css('#new_task')
  end

  def when_i_click_on_the_all_tasks_button
    find("#allTasksToggle", visible: :all).ancestor('div.toggle').click
  end

  def then_i_should_see_tasks_assigned_to_me_count(count)
    expect(page).to have_css("table.tasks tbody tr", count: count)
    expect(page).to have_css("span.badge", text: count.to_s, exact_text: true)
  end

  def then_i_should_see_the_task_is_assigned_to_the_identity(assignee)
    expect(page).to have_css("table.tasks tbody td:nth-child(2)", count: 1, text: /#{Regexp.quote(assignee.full_name)}/i)
  end
end
