require 'rails_helper'

RSpec.describe Component, type: :model do

  it { is_expected.to belong_to(:composable) }

  context 'class methods' do

    describe 'default_scope' do

      it 'should be scoped to position' do
        groups = []
        # create them with positions 3,2,1
        (3..1).each do |p|
          c = create(:component, position: p)
          groups << c
        end
        # expect them to return from query in position-order 1,2,3
        sorted_groups = Component.all
        expect(groups.first).to eq(sorted_groups.last)
        expect(groups.second).to eq(sorted_groups.second)
        expect(groups.third).to eq(sorted_groups.first)
      end
    end
  end
end 