require 'rails_helper'

RSpec.describe Subsidy, type: :model do

  it { is_expected.to belong_to(:sub_service_request) }

  context 'instance methods' do

    describe 'subsidy_committed' do

      it 'should return the correct amount in cents' do
        subsidy = build(:subsidy, pi_contribution: 450000, total_at_approval: 500000, status: 'Approved')
        expect(subsidy.subsidy_committed).to eq(50000)
      end
    end

    describe 'percent_subsidy' do

      it 'should return 0 if total_at_approval is blank' do
        subsidy = build(:subsidy, pi_contribution: 450000, total_at_approval: 0, status: 'Approved')
        expect(subsidy.percent_subsidy).to eq('0')
      end

      it 'should return 0 if total_at_approval is nil' do
        subsidy = build(:subsidy, pi_contribution: 450000, total_at_approval: nil, status: 'Approved')
        expect(subsidy.percent_subsidy).to eq('0')
      end

      it 'should return 35 if total_at_approval is nil' do
        subsidy = build(:subsidy, pi_contribution: 32200, total_at_approval: 49538, status: 'Approved')
        expect(subsidy.percent_subsidy).to eq('35.0')
      end
    end
  end
end
