require 'rails_helper'

RSpec.describe LineItem, type: :model do

  it { should belong_to(:arm) }
  it { should belong_to(:service) }

  it { should have_many(:visits).dependent(:destroy) }
  it { should have_many(:visit_groups) }

  context 'class methods' do

    describe 'default_scope' do

      it 'should order by :sparc_core_name' do
        line_item_2 = create(:line_item, sparc_core_name: 'Z')
        line_item_1 = create(:line_item, sparc_core_name: 'A')

        expect(LineItem.all).to eq([line_item_1, line_item_2])
      end
    end
  end

  context 'instance methods' do

    describe '.name' do

      it 'should be delegated to Service' do
        service   = create(:service, name: 'Test Service')
        line_item = create(:line_item, service: service)

        expect(line_item.name).to eq('Test Service')
      end
    end

    describe '.cost' do

      it 'should be delegated to Service' do
        service   = create(:service, cost: 1)
        line_item = create(:line_item, service: service)

        expect(line_item.cost).to eq(1)
      end
    end
  end
end
