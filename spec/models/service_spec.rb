require 'rails_helper'

RSpec.describe Service, type: :model do

  it { is_expected.to have_many(:line_items) }
  it { is_expected.to have_many(:service_level_components) }

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
  end
end
