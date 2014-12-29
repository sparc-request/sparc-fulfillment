require 'rails_helper'

RSpec.describe LineItem, type: :model do

  it { should belong_to(:arm) }
  it { should belong_to(:service) }

  it { should have_many(:visits) }

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
