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
