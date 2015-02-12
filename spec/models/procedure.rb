require 'rails_helper'

RSpec.describe Procedure, type: :model do

  it { is_expected.to belong_to(:appointment) }
  it { is_expected.to belong_to(:visit) }

  it { is_expected.to have_many(:notes) }

  context 'class methods' do

    describe '#delete' do

      it 'should not permanently delete the record' do
        procedure = create(:procedure)

        procedure.delete

        expect(procedure.reload.persisted?).to be
      end

      it 'should not destroy the record if the status is not nil' do
        procedure = create(:procedure, status: 'complete')

        expect{procedure.destroy}.to raise_error(ActiveRecord::ActiveRecordError)
      end
    end
  end
end
