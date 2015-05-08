require 'rails_helper'

RSpec.describe LineItem, type: :model do

  it { should belong_to(:arm) }
  it { should belong_to(:service) }

  it { should have_many(:visits).dependent(:destroy) }
  it { should have_many(:visit_groups) }
  it { should have_many(:notes) }
  it { should have_many(:documents) }
  it { should have_many(:fulfillments) }
  it { should have_many(:components) }

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
        service   = create(:service)
        line_item = create(:line_item, service: service)

        expect(line_item.cost).to eq(500.0)
      end
    end

    describe '.sparc_core_name' do

      it 'should be delegated to Service' do
        organization  = create(:organization_core, name: "Core A")
        service       = create(:service, organization: organization)
        line_item     = create(:line_item, service: service)

        expect(line_item.sparc_core_name).to eq('Core A')
      end
    end

    describe '.sparc_core_id' do

      it 'should be delegated to Service' do
        service       = create(:service)
        organization  = service.organization
        line_item     = create(:line_item, service: service)

        expect(line_item.sparc_core_id).to eq(organization.id)
      end
    end
  end
end
