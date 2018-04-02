# Copyright © 2011-2018 MUSC Foundation for Research Development~
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

require "rails_helper"

RSpec.describe PricingMap, type: :model do
  before(:each) do
    # TODO - this is just to get the specs to run, for some reason data is persisting between tests
    PricingMap.destroy_all
  end

  describe ".current" do

    context "no PricingMaps present" do

      it "should return an empty Array" do
        expect(PricingMap.current(Time.current)).to eq([])
      end
    end

    context "PricingMaps present" do

      context "one PricingMap present" do

        context ":effective_date is in the past" do

          it "should return the PricingMap" do
            pricing_map = create(:pricing_map_past)
            expect(PricingMap.current(Time.current)).to eq([pricing_map])
          end
        end

        context ":effective_date is today" do

          it "should return the PricingMap" do
            pricing_map = create(:pricing_map_present)
            expect(PricingMap.current(Time.current)).to eq([pricing_map])
          end
        end

        context ":effective_date is in the future" do

          it "should return an empty Array" do
            create(:pricing_map_future)
            expect(PricingMap.current(Time.current)).to eq([])
          end
        end
      end

      context "multiple PricingMaps present" do

        context "multiple PricingMaps present in the past" do

          it 'should return the PricingMap with the most recent effective_date' do
            expected_pricing_map = create(:pricing_map, effective_date: Time.current)
            create(:pricing_map_past, effective_date: Time.current - 2.days)
            expect(PricingMap.current(Time.current)).to eq([expected_pricing_map])
          end
        end

        context "PricingMaps in the past and future present" do

          it 'should return the past PricingMap' do
            expected_pricing_map = create(:pricing_map_past)
            create(:pricing_map_future)
            expect(PricingMap.current(Time.current)).to eq([expected_pricing_map])
          end
        end

        context "multiple PricingMaps present in the future" do

          it 'should return the empty Array' do
            create(:pricing_map_future)
            create(:pricing_map_future, effective_date: Time.current + 2.days)
            expect(PricingMap.current(Time.current)).to eq([])
          end
        end
      end
    end
  end
end
