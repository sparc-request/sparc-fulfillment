require 'rails_helper'

RSpec.describe IdentityCounter, type: :model do

  it { is_expected.to belong_to(:identity) }

  describe "#update_counter" do

    it 'should increment counter' do
      identity = create(:identity)
      identity_counter = create(:identity_counter, identity: identity, tasks_count: 0)

      IdentityCounter.update_counter(identity.id, :tasks, 1)
      expect(identity_counter.reload.tasks_count).to eq(1)
    end

    it 'should decrement counter' do
      identity = create(:identity)
      identity_counter = create(:identity_counter, identity: identity, tasks_count: 1)

      IdentityCounter.update_counter(identity.id, :tasks, -1)
      expect(identity_counter.reload.tasks_count).to eq(0)
    end

    it 'should not decrease counter below zero' do
      identity = create(:identity)
      identity_counter = create(:identity_counter, identity: identity, tasks_count: 0)

      IdentityCounter.update_counter(identity.id, :tasks, -1)
      expect(identity_counter.reload.tasks_count).to eq(0)
    end
  end
end
