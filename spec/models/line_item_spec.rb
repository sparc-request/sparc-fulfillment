require 'rails_helper'

RSpec.describe LineItem, type: :model do

  it { is_expected.to belong_to(:protocol) }
  it { is_expected.to belong_to(:arm) }
  it { is_expected.to belong_to(:service) }

  it { is_expected.to have_many(:visit_groups) }
  it { is_expected.to have_many(:visits).dependent(:destroy) }
  it { is_expected.to have_many(:fulfillments) }
  it { is_expected.to have_many(:notes) }
  it { is_expected.to have_many(:documents) }
  it { is_expected.to have_many(:components) }

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

    describe '.sparc_core_name' do

      it 'should be delegated to Service' do
        service   = create(:service, sparc_core_name: 'Core A')
        line_item = create(:line_item, service: service)

        expect(line_item.sparc_core_name).to eq('Core A')
      end
    end

    describe '.sparc_core_id' do

      it 'should be delegated to Service' do
        service   = create(:service, sparc_core_id: 4)
        line_item = create(:line_item, service: service)

        expect(line_item.sparc_core_id).to eq(4)
      end
    end

    describe '.one_time_fee' do

      it 'should be delegated to Service' do
        service   = create(:service, one_time_fee: true)
        line_item = create(:line_item, service: service)

        expect(line_item.one_time_fee).to eq(true)
      end
    end
  end

  context 'class methods' do

    describe 'quantity_remaining' do

      it 'should return the quantity_requested minus the quantity of each fulfillment' do
        service   = create(:service, one_time_fee: true)
        line_item = create(:line_item, service: service, quantity_requested: 500)
        4.times do
          create(:fulfillment, line_item: line_item, quantity: 25)
        end

        expect(line_item.quantity_remaining).to eq(400)
      end

      it 'should return quantity_requested if there are no fulfillments' do
        service   = create(:service, one_time_fee: true)
        line_item = create(:line_item, service: service, quantity_requested: 500)

        expect(line_item.quantity_remaining).to eq(500)
      end
    end

    describe 'last_fulfillment' do

      it 'should return the fulfilled_at date of the latest fulfillment' do
        service   = create(:service, one_time_fee: true)
        line_item = create(:line_item, service: service)
        fill_1 = create(:fulfillment, line_item: line_item, fulfilled_at: Date.today - 2.weeks)
        fill_2 = create(:fulfillment, line_item: line_item, fulfilled_at: Date.today - 1.week)
        fill_3 = create(:fulfillment, line_item: line_item, fulfilled_at: Date.today - 1.day)

        expect(line_item.last_fulfillment).to eq(fill_3.fulfilled_at)
      end
    end
  end
end
