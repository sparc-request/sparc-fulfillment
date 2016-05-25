require 'rails_helper'

RSpec.describe Subsidy, type: :model do

  it { is_expected.to belong_to(:sub_service_request) }

  context 'instance methods' do

    describe 'subsidy_committed' do

      it 'should return the correct amount in cents' do
        subsidy = create(:subsidy, pi_contribution: 450000, total_at_approval: 500000, status: 'Approved')
        expect(subsidy.subsidy_committed).to eq(50000)
      end
    end
  end
end
