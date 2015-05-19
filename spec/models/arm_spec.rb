require 'rails_helper'

RSpec.describe Arm, type: :model do

  it { should belong_to(:protocol) }

  it { should have_many(:line_items).dependent(:destroy) }
  it { should have_many(:visit_groups).dependent(:destroy) }
  it { should have_many(:participants) }
  it { should have_many(:appointments) }

  it { should validate_presence_of(:name) }
  it { should validate_numericality_of(:subject_count).is_greater_than_or_equal_to(1) }
  it { should validate_numericality_of(:visit_count).is_greater_than_or_equal_to(1) }

  context 'class methods' do

    describe '.line_items_grouped_by_core' do

      it 'should return LineItems grouped by core' do
        protocol  = create(:protocol)
        arm       = create(:arm)
        service_1 = create(:service)
        service_2 = create(:service)
        create(:line_item, arm: arm, service: service_1, subject_count: 1, protocol: protocol)
        create(:line_item, arm: arm, service: service_2, subject_count: 2, protocol: protocol)
        create(:line_item, arm: arm, service: service_2, subject_count: 2, protocol: protocol)

        expect(arm.line_items_grouped_by_core.length).to eq(2)
        expect(arm.line_items_grouped_by_core[service_1.organization.id].length).to eq(1)
        expect(arm.line_items_grouped_by_core[service_2.organization.id].length).to eq(2)
        expect(arm.line_items_grouped_by_core[service_2.organization.id].map(&:subject_count).uniq.first).to eq(2)
      end
    end

    describe '#delete' do

      it 'should not permanently delete the record' do
        arm = create(:arm)

        arm.delete

        expect(arm.persisted?).to be
      end
    end
  end
end
