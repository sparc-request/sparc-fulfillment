require 'rails_helper'

RSpec.describe Arm, type: :model do

  it { should belong_to(:protocol) }

  it { should have_many(:line_items).dependent(:destroy) }
  it { should have_many(:visit_groups).dependent(:destroy) }
  it { should have_many(:participants) }

  it { should accept_nested_attributes_for(:line_items) }
  it { should accept_nested_attributes_for(:visit_groups) }

  it { should validate_presence_of(:name) }
  it { should validate_numericality_of(:subject_count).is_greater_than_or_equal_to(1) }
  it { should validate_numericality_of(:visit_count).is_greater_than_or_equal_to(1) }

  context 'class methods' do

    describe '.line_items_grouped_by_core' do

      it 'should return LineItems grouped by core' do
        arm       = create(:arm)
        service_1 = create(:service, sparc_core_id: 1)
        service_2 = create(:service, sparc_core_id: 2)
        service_3 = create(:service, sparc_core_id: 2)

        create(:line_item, arm: arm, service: service_1, subject_count: 1)
        create(:line_item, arm: arm, service: service_2, subject_count: 2)
        create(:line_item, arm: arm, service: service_3, subject_count: 2)

        expect(arm.line_items_grouped_by_core.length).to eq(2)
        expect(arm.line_items_grouped_by_core[1].length).to eq(1)
        expect(arm.line_items_grouped_by_core[2].length).to eq(2)
        expect(arm.line_items_grouped_by_core[2].map(&:subject_count).uniq.first).to eq(2)
      end
    end

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
