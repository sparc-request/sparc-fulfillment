require "rails_helper"

RSpec.describe Task, type: :model do

  it { is_expected.to belong_to(:identity) }
  it { is_expected.to belong_to(:assignee).counter_cache(true) }
  it { is_expected.to belong_to(:assignable) }

  it { is_expected.to validate_presence_of(:assignee_id) }

  describe "identity_counter update methods" do

    it "should increment the task counter whenever a task is added" do
      identity       = create(:identity)
      previous_count = identity.identity_counter.task_count
      task           = create(:task, identity: identity)
      expect(identity.identity_counter.task_count).to eq(previous_count + 1)
    end

    it "should increment the task counter whenever a task is changed from complete to incomplete" do
    end

    it "should decrement the task counter whenever a task is completed" do
    end

    it "should decrement the task counter whenever an incomplete task is destroyed" do
    end

    it "should not change the task counter whenever a completed task is destroyed" do
    end
  end
end
