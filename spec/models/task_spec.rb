require "rails_helper"

RSpec.describe Task, type: :model do

  it { is_expected.to belong_to(:identity) }
  it { is_expected.to belong_to(:assignee) }
  it { is_expected.to belong_to(:assignable) }

  it { is_expected.to validate_presence_of(:assignee_id) }

  describe "identity counter update methods" do

    it "should increment the task counter whenever a task is added" do
      an_identity_that_is_assigned_an_incomplete_task
      should_have_1_task
    end

    it "should increment the task counter whenever a task is changed from complete to incomplete" do
      an_identity_that_is_assigned_an_incomplete_task
      then_completes_it
      then_incompletes_it
      should_have_1_task
    end

    it "should decrement the task counter whenever a task is completed" do
      an_identity_that_is_assigned_an_incomplete_task
      then_completes_it
      should_have_no_tasks
    end

    it "should not change the task counter whenever a completed task is added" do
      an_identity_that_is_assigned_a_complete_task
      should_have_no_tasks
    end

    it "should decrement the task counter whenever an incomplete task is destroyed" do
      an_identity_that_is_assigned_an_incomplete_task
      and_the_task_is_destroyed
      should_have_no_tasks
    end

    it "should not change the task counter whenever a completed task is destroyed" do
      an_identity_that_is_assigned_an_incomplete_task
      and_another
      then_completes_it
      and_the_task_is_destroyed
      should_have_1_task
    end
  end

  def an_identity_that_is_assigned_an_incomplete_task
    @identity = create(:identity)
    @task     = create(:task, identity: @identity)
  end

  def and_another
    @task     = create(:task, identity: @identity)
  end

  def an_identity_that_is_assigned_a_complete_task
    @identity = create(:identity)
    @task     = create(:task_complete, identity: @identity)
  end
    
  def then_completes_it
    @task.update(complete: true)
  end

  def then_incompletes_it
    @task.update(complete: false)
  end

  def and_the_task_is_destroyed
    @task.destroy
  end

  def should_have_1_task
    expect(@identity.tasks_count).to eq(1)
  end

  def should_have_no_tasks
    expect(@identity.tasks_count).to eq(0)
  end

end
