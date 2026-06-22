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

RSpec.describe "Rescheduling a Task", type: :system, js: true do
  let(:identity)    { @logged_in_identity }
  let(:tasks)       { create_list(:task, 2, identity: identity, assignee: identity) }
  
  let(:target_date) { Date.today.next_month.change(day: 15) } 

  it "Identity reschedules a Task" do
    given_i_have_an_assigned_task
    when_i_reschedule_the_task
    then_i_should_see_the_task_has_been_rescheduled
  end

  def given_i_have_an_assigned_task
    tasks 

    visit tasks_path
    
    expect(page).to have_css("table.tasks tbody tr", count: 2)
  end

  def when_i_reschedule_the_task
    find('a.reschedule-task', match: :first).click

    expect(page).to have_css('.modal.show', text: /Reschedule/i, visible: true)

    formatted_date = target_date.strftime('%m/%d/%Y')

    within('.modal.show', text: /Reschedule/i) do
      # Loop until the JS is fully initialized and accepts our value, then safely blur by clicking the `.modal-title` instead of the page backdrop
      while find('.datetimepicker-input').value != formatted_date
        find('.datetimepicker-input').set(formatted_date)
        find('.modal-title', text: /Reschedule/i).click 
      end
      
      click_button "Submit"
    end

    expect(page).to have_no_css('.modal.show', text: /Reschedule/i)
  end

  def then_i_should_see_the_task_has_been_rescheduled
    # Extract the day from the let block variable dynamically
    target_day = target_date.strftime('%d')
    
    expect(page).to have_css("table.tasks tbody tr td", text: /\/#{target_day}\//)
  end
end
