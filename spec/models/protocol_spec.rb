require 'rails_helper'

RSpec.describe Protocol, type: :model do

  it { should have_many(:arms).dependent(:destroy) }
  it { should have_many(:participants).dependent(:destroy) }

  context 'class methods' do

    describe '#delete' do

      it 'should not permanently delete the record' do
        service = create(:service)

        service.delete

        expect(service.persisted?).to be
      end
    end

    describe 'callbacks' do

      it 'should callback :update_via_faye after save' do
        protocol = create(:protocol)

        expect(protocol).to callback(:update_faye).after(:save)
      end
    end
  end

  context 'instance methods' do

    describe 'subsidy_committed' do

      it 'should return the correct amount in cents' do
        protocol = create(:protocol, study_cost: 5000, stored_percent_subsidy: 10.00)

        expect(protocol.subsidy_committed).to eq(500)
      end
    end
  end
end
