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

RSpec.describe "Task notifications", type: :system, js: true do
  let(:identity) { @logged_in_identity }
  let(:assignor) { create(:identity) }
  
  let(:task)     { create(:task, identity: assignor, assignee: identity) }

  it "Identity sees that they have no Tasks" do
    given_i_have_no_tasks
    when_i_visit_the_task_page
    then_i_should_see_that_i_have_no_tasks
  end

  it "Identity sees that they have one assigned Task" do
    given_i_have_one_task
    when_i_visit_the_task_page
    then_i_should_see_that_i_have_one_task
  end

  it "Identity completes a task and sees the notification badge clear" do
    given_i_have_one_task
    when_i_visit_the_task_page
    when_i_complete_the_task
    then_i_should_be_on_the_tasks_page
    then_i_should_see_that_i_have_no_tasks
  end

  def given_i_have_no_tasks
    # Database cleaner setup takes care of erasing tasks between runs
  end

  def given_i_have_one_task
    # Explicitly invoke the lazy let block to build the single task in the database
    task
  end

  def when_i_visit_the_task_page
    visit tasks_path
    
    expect(page).to have_css("body.tasks-index", visible: :all)
  end

  def when_i_complete_the_task
    find("input[type='checkbox']", match: :first).set(true)
  end

  def then_i_should_be_on_the_tasks_page
    expect(page).to have_css("body.tasks-index", visible: :all)
  end

  def then_i_should_see_that_i_have_no_tasks
    expect(page).to have_no_css(".notification-badge")
  end

  def then_i_should_see_that_i_have_one_task
    expect(page).to have_css(".notification-badge", text: "1", exact_text: true)
  end
end
