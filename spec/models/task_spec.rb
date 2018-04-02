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

RSpec.describe Task, type: :model do

  it { is_expected.to belong_to(:identity) }
  it { is_expected.to belong_to(:assignee) }
  it { is_expected.to belong_to(:assignable) }

  it { is_expected.to validate_presence_of(:assignee_id) }
  it { is_expected.to validate_presence_of(:due_at) }

  describe "identity counter update methods" do

    it "should increment the assignee task counter when a task is added by another Identity" do
      an_identity_is_assigned_a_task_by_another_identity
      assignee_should_have_1_task
    end

    it "should increment the assignee task counter when a task is self-assigned" do
      an_identity_assigns_a_task_to_themself
      identity_should_have_1_task
    end

    it "should increment the assignee task counter whenever a task is changed from complete to incomplete" do
      an_identity_is_assigned_a_task_by_another_identity
      assignee_completes_the_task
      assignee_incompletes_the_task
      assignee_should_have_1_task
    end

    it "should decrement the task counter whenever a task is completed" do
      an_identity_is_assigned_a_task_by_another_identity
      assignee_completes_the_task
      assignee_should_have_no_tasks
    end

    it "should not change the task counter whenever a completed task is added" do
      an_identity_that_is_assigned_a_complete_task
      assignee_should_have_no_tasks
    end

    it "should decrement the task counter whenever an incomplete task is destroyed" do
      an_identity_is_assigned_a_task_by_another_identity
      and_the_task_is_destroyed
      assignee_should_have_no_tasks
    end

    it "should not change the task counter whenever a completed task is destroyed" do
      an_identity_is_assigned_a_task_by_another_identity
      an_identity_is_assigned_another_task_by_another_identity
      assignee_completes_the_task
      and_the_task_is_destroyed
      assignee_should_have_1_task
    end
  end

  def an_identity_is_assigned_a_task_by_another_identity
    @identity   = create(:identity)
    @assignee   = create(:identity)
    @task       = create(:task_incomplete, identity: @identity, assignee: @assignee)
  end

  def an_identity_assigns_a_task_to_themself
    @identity   = create(:identity)
    @task       = create(:task_incomplete, identity: @identity, assignee: @identity)
  end

  def an_identity_is_assigned_another_task_by_another_identity
    create(:task_incomplete, identity: @identity, assignee: @assignee)
  end

  def an_identity_that_is_assigned_a_complete_task
    @identity = create(:identity)
    @task     = create(:task_complete, identity: @identity)
  end

  def assignee_completes_the_task
    @task.update_attribute :complete, true
  end

  def assignee_incompletes_the_task
    @task.update_attribute :complete, false
  end

  def assignee_should_have_1_task
    expect(@assignee.tasks_count).to eq(1)
  end

  def and_the_task_is_destroyed
    @task.destroy
  end

  def identity_should_have_1_task
    expect(@identity.tasks_count).to eq(1)
  end

  def assignee_should_have_no_tasks
    expect(@identity.tasks_count).to eq(0)
  end
end
