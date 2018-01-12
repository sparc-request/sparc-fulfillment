# Copyright © 2011-2017 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

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

  context 'validations' do

    it { is_expected.to validate_presence_of(:protocol_id) }
    it { is_expected.to validate_presence_of(:service_id) }

    describe 'custom validations' do

      it 'should validate presence of quantity_requested and quantity type if one_time_fee' do
        service = create(:service_with_one_time_fee) #otf true
        line_item = LineItem.new(service: service, protocol: create(:protocol), quantity_requested: nil)
        expect(line_item).to have(2).errors_on(:quantity_requested)
      end
      it 'should not validate presence of quantity_requested if not one_time_fee' do
        service = create(:service) #otf false
        line_item = LineItem.new(service: service, protocol: create(:protocol), quantity_requested: nil)
        expect(line_item).to have(0).errors_on(:quantity_requested)
      end
    end
  end

  context 'instance methods' do

    describe '.name' do

      it 'should be equal to Service name when Service does not have a one time fee' do
        service   = create(:service)
        line_item = create(:line_item_with_fulfillments, service: service, protocol: create(:protocol))
        service.update_attributes(name: service.name + '_')
        expect(line_item.name).to eq(service.name)
      end

      it 'should be equal to Service name when Line Item has no Fulfillments' do
        service   = create(:service_with_one_time_fee)
        line_item = create(:line_item, service: service, protocol: create(:protocol))
        service.update_attributes(name: service.name + '_')
        expect(line_item.name).to eq(service.name)
      end

      it 'should be equal to Service name at the time Line Item gains a Fulfillment' do
        service   = create(:service_with_one_time_fee)
        line_item = create(:line_item_with_fulfillments, service: service, protocol: create(:protocol))
        name      = service.name
        service.update_attributes(name: service.name + '_')
        expect(line_item.name).to eq(name)
      end
    end

    describe '.cost' do

      it 'should be delegated to Service' do
        service   = create(:service)
        line_item = create(:line_item, service: service, protocol: create(:protocol))

        expect(line_item.cost).to eq(500.0)
      end
    end

    describe '.sparc_core_name' do

      it 'should be delegated to Service' do
        organization  = create(:organization_core, name: "Core A")
        service       = create(:service, organization: organization)
        line_item     = create(:line_item, service: service, protocol: create(:protocol))

        expect(line_item.sparc_core_name).to eq('Core A')
      end
    end

    describe '.sparc_core_id' do

      it 'should be delegated to Service' do
        service       = create(:service)
        organization  = service.organization
        line_item     = create(:line_item, service: service, protocol: create(:protocol))

        expect(line_item.sparc_core_id).to eq(organization.id)
      end
    end

    describe '.one_time_fee' do

      it 'should be delegated to Service' do
        service   = create(:service_with_one_time_fee)
        line_item = create(:line_item, service: service, protocol: create(:protocol))

        expect(line_item.one_time_fee).to eq(true)
      end
    end
  end

  context 'class methods' do

    describe 'quantity_remaining' do

      it 'should return the quantity_requested minus the quantity of each fulfillment' do
        service   = create(:service_with_one_time_fee)
        line_item = create(:line_item, service: service, protocol: create(:protocol), quantity_requested: 500)
        4.times do
          create(:fulfillment, line_item: line_item, quantity: 25)
        end

        expect(line_item.quantity_remaining).to eq(400)
      end

      it 'should return quantity_requested if there are no fulfillments' do
        service   = create(:service_with_one_time_fee)
        line_item = create(:line_item, service: service, protocol: create(:protocol), quantity_requested: 500)

        expect(line_item.quantity_remaining).to eq(500)
      end
    end

    describe 'last_fulfillment' do

      it 'should return the fulfilled_at date of the latest fulfillment' do
        service   = create(:service_with_one_time_fee)
        line_item = create(:line_item, service: service, protocol: create(:protocol))
        fill_1 = create(:fulfillment_without_validations, line_item: line_item, fulfilled_at: "08/10/2015")
        fill_2 = create(:fulfillment_without_validations, line_item: line_item, fulfilled_at: "09/10/2015")
        fill_3 = create(:fulfillment_without_validations, line_item: line_item, fulfilled_at: "10/10/2015")

        expect(line_item.last_fulfillment).to eq(fill_3.fulfilled_at)
      end
    end

    describe 'create_line_item_components' do

      it 'should create components for the line_item after creation' do
        service = create(:service_with_one_time_fee)
        expect{
          create(:line_item, service: service, protocol: create(:protocol))
        }.to change(Component, :count).by(3)
      end
    end
  end

  context 'class methods' do

    describe "after create" do

      it "should increment service line_item_count" do
        service = create(:service)
        expect { create(:line_item, service: service, protocol: create(:protocol)) }.to change{service.line_items_count}.by(1)
      end
    end

    describe "after destroy" do

      it "should decrement service line_item_count" do
        service = create(:service)
        line_item = create(:line_item, service: service, protocol: create(:protocol))
        expect { line_item.destroy }.to change{service.line_items_count}.by(-1)
      end
    end
  end
end
