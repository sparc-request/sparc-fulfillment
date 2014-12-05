require 'rails_helper'

RSpec.describe Protocol, type: :model do

  it { should have_many(:arms) }

  describe 'set subsidy committed' do
    let!(:protocol)  { create(:protocol, study_cost: 5000, stored_percent_subsidy: 10.00)}

    it "should corrrectly calculate and set the subsidy committed field in the database" do
      protocol.set_subsidy_committed
      expect(protocol.subsidy_committed).to eq(5.00)
    end
  end
end
