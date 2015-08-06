require 'rails_helper'

RSpec.describe StudyLevelActivitiesHelper do

  describe "#components_for_select" do
    it "should return components options" do
      components = []
      #No components
      val = helper.components_for_select(components)
      expect(val.include? 'value="This Service Has No Components"')

      #Components
      3.times do
        components << create(:component)
      end
      val = helper.components_for_select(components)
      expect(val.include? 'value="1"')
      expect(val.include? 'value="2"')
      expect(val.include? 'value="3"')
    end
  end
end
