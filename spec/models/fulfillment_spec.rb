require 'rails_helper'

RSpec.describe Fulfillment, type: :model do

  it { is_expected.to belong_to(:line_item) }
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

end 