# Copyright © 2011-2016 MUSC Foundation for Research Development~
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
