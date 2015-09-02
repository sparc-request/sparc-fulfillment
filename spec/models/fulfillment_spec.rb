require 'rails_helper'

RSpec.describe Fulfillment, type: :model do

  it { is_expected.to belong_to(:line_item) }
  it { is_expected.to belong_to(:service) }
  it { is_expected.to belong_to(:performer) }
  it { is_expected.to belong_to(:creator) }

  it { is_expected.to have_many(:components) }
  it { is_expected.to have_many(:notes) }
  it { is_expected.to have_many(:documents) }

  context 'validations' do

    it { is_expected.to validate_presence_of(:line_item_id) }
    it { is_expected.to validate_presence_of(:fulfilled_at) }
    it { is_expected.to validate_presence_of(:quantity) }
    it { is_expected.to validate_presence_of(:performer_id) }
    it { is_expected.to validate_numericality_of(:quantity) }
  end

  context 'instance methods' do

    describe '.quantity_type' do

      it 'should be delegated to LineItem' do
        line_item = create(:line_item, protocol: create(:protocol), service: create(:service), quantity_type: 'Each')
        fulfillment = create(:fulfillment, line_item: line_item)

        expect(fulfillment.quantity_type).to eq(line_item.quantity_type)
      end
    end
  end

  describe 'after create' do

    context 'associated Line Item has one time fee' do

      it 'should set the Line Item name when Line Item previously had no Fulfillments' do
        service   = create(:service_with_one_time_fee)
        line_item = create(:line_item, service: service, protocol: create(:protocol))
        create(:fulfillment, line_item: line_item)
        expect(line_item.read_attribute(:name)).to eq(service.name)
      end

      it 'should not set the Line Item name again when another Fulfillment is added' do
        service   = create(:service_with_one_time_fee)
        name      = service.name
        line_item = create(:line_item, service: service, protocol: create(:protocol))
        create(:fulfillment, line_item: line_item)
        service.update_attributes(name: service.name + '_')
        create(:fulfillment, line_item: line_item)
        expect(line_item.read_attribute(:name)).to eq(name)
      end
    end

    context 'associated Line Item has no one time fee' do

      it 'should not set the Line Item name when Line Item previously had no Fulfillments' do
        service   = create(:service)
        line_item = create(:line_item, service: service, protocol: create(:protocol))
        create(:fulfillment, line_item: line_item)
        expect(line_item.read_attribute(:name)).to_not be
      end

      it 'should not set the Line Item name when multiple Fulfillments are added' do
        service   = create(:service)
        line_item = create(:line_item, service: service, protocol: create(:protocol))
        2.times { create(:fulfillment, line_item: line_item) }
        expect(line_item.read_attribute(:name)).to_not be
      end
    end
  end
end
