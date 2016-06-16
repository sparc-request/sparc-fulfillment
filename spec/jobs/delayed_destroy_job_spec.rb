require 'rails_helper'

RSpec.describe DelayedDestroyJob, type: :job do
  describe '#enqueue' do

    it 'should create a Active::Job' do
      arm = create(:arm)
      arm.destroy_later

      expect(DelayedDestroyJob).to have_been_enqueued
    end
  end
end
