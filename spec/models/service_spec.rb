require 'rails_helper'

RSpec.describe Service, type: :model do

  it { is_expected.to have_many(:line_items) }
  it { is_expected.to have_many(:pricing_maps) }

  context 'class methods' do

    describe '.default_scope' do

      it 'should order services by name' do
        orange_service = create(:service, name: "Orange")
        apple_service = create(:service, name: "Apple")

        all_services = Service.all
        apple_index = all_services.index(apple_service)
        orange_index = all_services.index(orange_service)

        expect(apple_index < orange_index).to be
      end
    end

    describe '.cost' do

      context 'current PricingMap not present' do

        it 'should raise an ArgumentError' do
          service = create(:service)
          service.pricing_maps.destroy_all

          expect { service.cost }.to raise_error(ArgumentError)
        end
      end

      context 'current PricingMap is present' do

        it 'should return the full rate of the PricingMap' do
          service = create(:service)
          pricing_map = create(:pricing_map_past, service: service, full_rate: 500.0)

          expect(service.cost).to eq(500.0)
        end
      end
    end

    describe 'current_effective_pricing_map' do

      let!(:service)      { create(:service, name: 'Service') }
      let!(:pricing_map1) { create(:pricing_map, service: service, effective_date: Time.current)}
      let!(:pricing_map2) { create(:pricing_map, service: service, effective_date: Time.now + 1.month)}

      it 'should return the correct pricing map' do
        expect(service.current_effective_pricing_map).to eq(pricing_map1)
      end
    end
  end
end
