# Copyright © 2011-2016 MUSC Foundation for Research Development~
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
