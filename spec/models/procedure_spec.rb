require 'rails_helper'

RSpec.describe Procedure, type: :model do

  it { is_expected.to belong_to(:appointment) }
  it { is_expected.to belong_to(:visit) }

  it { is_expected.to have_many(:notes) }

  it { should accept_nested_attributes_for(:notes) }

  it { is_expected.to validate_inclusion_of(:status).in_array(Procedure::STATUS_TYPES) }

  context 'class methods' do

    describe '#delete' do

      it 'should not permanently delete the record' do
        procedure = create(:procedure)

        procedure.delete

        expect(procedure.reload.persisted?).to be
      end

      it 'should destroy the record if the status is nil' do
        procedure = create(:procedure)

        procedure.destroy

        expect(Procedure.count).to eq(0)
      end

      it 'should not destroy the record if the status is not nil' do
        procedure = create(:procedure, status: 'complete')

        expect{procedure.destroy}.to raise_error(ActiveRecord::ActiveRecordError)
      end
    end
  end
end
