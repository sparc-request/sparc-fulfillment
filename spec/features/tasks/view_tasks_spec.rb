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

feature "View Tasks", js: true do

  scenario "Identity with no Tasks views Tasks list" do
    given_i_have_no_tasks
    when_i_visit_the_tasks_page
    then_i_should_see_that_i_have_no_tasks
  end

  scenario "Identity views complete Tasks" do
    given_i_have_complete_tasks
    when_i_view_complete_tasks
    then_i_should_see_complete_tasks
  end

  scenario "Identity views only their Tasks" do
    given_other_users_have_assigned_tasks
    when_i_visit_the_tasks_page
    then_i_should_only_see_tasks_assigned_to_me
  end

  scenario "Identity initially views only incomplete Tasks" do
    given_i_have_complete_and_incomplete_tasks
    when_i_visit_the_tasks_page
    then_i_should_see_only_incomplete_tasks
  end

  scenario "Identity views tasks assigned to someone else" do
    given_other_tasks_have_been_assigned_to_a_different_identity
    when_i_visit_the_tasks_page
    when_click_on_the_view_all_tasks_button
    then_i_should_see_all_tasks
  end

  def given_i_have_incomplete_tasks
    @identity = Identity.first

    create_list(:task, 2, identity: @identity)
  end

  def given_i_have_complete_tasks
    @identity = Identity.first

    create_list(:task_complete, 2, identity: @identity)
  end

  def given_other_users_have_assigned_tasks
    given_i_have_incomplete_tasks
    other_user = create(:identity)
    create_list(:task, 2, identity: other_user, assignee: other_user)
  end

  def given_other_tasks_have_been_assigned_to_a_different_identity
    given_i_have_incomplete_tasks

    other_user = create(:identity)
    create_list(:task, 2, identity: other_user, assignee: other_user)
  end

  def given_i_have_complete_and_incomplete_tasks
    given_i_have_incomplete_tasks
    given_i_have_complete_tasks
  end

  def as_a_identity_with_complete_tasks
    identity = Identity.first

    identity.tasks.push build(:task_complete, assignee_id: identity.id)
  end

  def given_i_have_no_tasks
    # Devise#sign_in
  end

  def when_i_view_complete_tasks
    when_i_visit_the_tasks_page
    find("#complete", visible: false).find(:xpath, "..").click
  end

  def when_i_visit_the_tasks_page
    visit tasks_path
    wait_for_ajax
  end

  def when_click_on_the_view_all_tasks_button
    find("#all_tasks", visible: false).find(:xpath, "..").click
  end

  def then_i_should_see_that_i_have_no_tasks
    expect(page).to have_css("table.tasks", text: "No matching records found")
  end

  def then_i_should_see_complete_tasks
    expect(page).to have_css("table.tasks input[checked]")
  end

  def then_i_should_only_see_tasks_assigned_to_me
    expect(page).to have_css("table.tasks tbody tr", count: 2)
  end

  def then_i_should_see_only_incomplete_tasks
    expect(page).to_not have_css("table.tasks tbody input[checked]")
  end

  def then_i_should_see_all_tasks
    expect(page).to have_css("table.tasks tbody tr", count: 4)
  end
end
