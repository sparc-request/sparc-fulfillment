require 'rails_helper'

RSpec.describe VisitGroup, type: :model do

  it { should belong_to(:arm) }

  it { should have_many(:visits).dependent(:destroy) }

  context 'class methods' do

    describe '.per_page' do

      it 'should inherit from Visit' do
        expect(VisitGroup.per_page).to eq(Visit.per_page)
      end
    end

    describe '#delete' do

      it 'should not permanently delete the record' do
        visit_group = create(:visit_group)

        visit_group.delete

        expect(visit_group.persisted?).to be
      end
    end
  end
end
