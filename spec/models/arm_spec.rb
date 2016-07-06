require 'rails_helper'

RSpec.describe Arm, type: :model do

  it { is_expected.to belong_to(:protocol) }

  it { is_expected.to have_many(:line_items).dependent(:destroy) }
  it { is_expected.to have_many(:visit_groups).dependent(:destroy) }
  it { is_expected.to have_many(:appointments) }
  it { is_expected.to have_many(:participants) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_numericality_of(:subject_count).is_greater_than_or_equal_to(1) }
  it { is_expected.to validate_numericality_of(:visit_count).is_greater_than_or_equal_to(1) }

  context 'class methods' do
    describe '#delete' do

      it 'should not permanently delete the record' do
        arm = create(:arm)

        arm.delete

        expect(arm.persisted?).to be
      end
    end
  end
end
