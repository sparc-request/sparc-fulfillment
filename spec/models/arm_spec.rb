require 'rails_helper'

RSpec.describe Arm, type: :model do

  it { should belong_to(:protocol) }

  it { should have_many(:line_items).dependent(:destroy) }
  it { should have_many(:visit_groups).dependent(:destroy) }
  it { should have_many(:participants) }

  it { should validate_presence_of(:name) }
  it { should validate_numericality_of(:subject_count).is_greater_than_or_equal_to(1) }
  it { should validate_numericality_of(:visit_count).is_greater_than_or_equal_to(1) }

  context 'class methods' do

    describe '#delete' do

      it 'should not permanently delete the record' do
        arm = create(:arm)

        arm.delete

        expect(arm.persisted?).to be
      end
    end

    describe 'callbacks' do

      describe '#create_visit_groups' do

        it 'should callback #create_visit_groups after #create' do
          arm = create(:arm)

          expect(arm).to callback(:create_visit_groups).after(:create)
        end

        it 'should import VisitGroups' do
          arm = create(:arm, visit_count: 2)

          expect(arm.visit_groups.count).to eq(2)
        end
      end
    end
  end

  context 'instance methods' do

  end
end
