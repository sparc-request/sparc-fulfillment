require 'rails_helper'

RSpec.describe Service, type: :model do

  it { is_expected.to have_many(:line_items).dependent(:destroy) }
  it { is_expected.to have_many(:components) }

  context 'class methods' do

    describe '#delete' do

      it 'should not permanently delete the record' do
        service = create(:service)

        service.delete

        expect(service.persisted?).to be
      end
    end

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
  end
end
