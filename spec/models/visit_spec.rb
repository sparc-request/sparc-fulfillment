require 'rails_helper'

RSpec.describe Visit, type: :model do

  it { is_expected.to belong_to(:line_item) }
  it { is_expected.to belong_to(:visit_group) }

  it { is_expected.to have_many(:procedures) }

  context 'class methods' do

    describe '#destroy' do

      it 'should destroy associated incomplete Procedures' do
        visit = create(:visit_with_complete_and_incomplete_procedures)

        visit.destroy

        expect(visit.procedures.count).to eq(3)
        expect(visit.procedures.complete.count).to eq(3)
        expect(visit.procedures.incomplete.count).to eq(0)
      end
    end

    describe '#delete' do

      it 'should not permanently delete the record' do
        visit = create(:visit)

        visit.delete

        expect(visit.persisted?).to be
      end
    end
  end

  context 'instance methods' do

    describe 'has_billing?' do

      context 'billing present' do

        it 'should reutrn: true' do
          visit = create(:visit_with_billing)

          expect(visit.has_billing?).to be
        end
      end

      context 'billing not present' do

        it 'should return: false' do
          visit = create(:visit_without_billing)

          expect(visit.has_billing?).to_not be
        end
      end
    end

    describe '.position' do

      it 'should delegate to VisitGroup' do
        visit_group = create(:visit_group_with_arm, position: 1)
        visit       = create(:visit, visit_group: visit_group)

        expect(visit.position).to eq(1)
      end
    end
  end
end
