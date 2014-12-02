require 'rails_helper'

RSpec.describe Protocol, type: :model do

  it { should have_many(:arms) }

  describe '#after_save', delay: true do

    before { create(:protocol) }

    it 'should create a ProtocolUpdater delayed_job' do
      expect(Delayed::Job.where("handler LIKE '%ProtocolUpdaterJob%'").one?).to be
    end
  end
end
