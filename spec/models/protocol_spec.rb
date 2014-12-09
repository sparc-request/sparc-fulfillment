require 'rails_helper'

RSpec.describe Protocol, type: :model do

  it { should have_many(:arms) }


  describe 'set subsidy committed' do
    let!(:protocol)  { create(:protocol, study_cost: 5000, stored_percent_subsidy: 10.00)}

    it "should corrrectly calculate and set the subsidy committed field in the database" do
      expect(protocol.subsidy_committed).to eq("$5.00")
    end
  end

  describe '#after_save', delay: true do

    before { create(:protocol) }

    it 'should create a RemoteObjectUpdaterJob delayed_job' do
      expect(Delayed::Job.where("handler LIKE '%RemoteObjectUpdaterJob%'").one?).to be
    end
  end
end
