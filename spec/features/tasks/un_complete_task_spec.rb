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

feature "un-completing a Task", js: true do

  scenario "Identity sets a completed Task to incomplete" do
    given_i_have_set_a_task_to_complete
    when_i_set_the_task_to_incomplete
    then_i_should_see_that_the_task_is_incomplete
  end

  def given_i_have_set_a_task_to_complete
    assignee = Identity.first
    assignor = create(:identity)
    create_list(:task, 2, identity: assignor, assignee: assignee)

    visit tasks_path
    wait_for_ajax

    first('input.complete').click
    wait_for_ajax
    expect(page).to have_css("table.tasks tbody tr", count: 1)
  end

  def when_i_set_the_task_to_incomplete
    find("label.toggle-off", text: 'Incomplete').click
    wait_for_ajax
    first('input.complete').click
    wait_for_ajax
  end

  def then_i_should_see_that_the_task_is_incomplete
    find("label.toggle-on", text: 'Complete').click
    wait_for_ajax
    expect(page).to have_css("table.tasks tbody tr", count: 2)
  end
end
