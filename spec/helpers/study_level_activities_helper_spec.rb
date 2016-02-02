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

  describe "is protocol of type study?" do
    it "should return true" do

      protocol = create(:protocol)
      sparc_protocol = protocol.sparc_protocol
      sparc_protocol.update_attributes(type: 'Study')

      is_study = helper.is_protocol_type_study? (protocol)

      expect(is_study).to eq Sparc::Protocol.where(id: protocol.sparc_id).first.type == 'Study'
    end

    it "should return false" do

      protocol = create(:protocol)
      sparc_protocol = protocol.sparc_protocol
      sparc_protocol.update_attributes(type: 'Project')

      is_study = helper.is_protocol_type_study? (protocol)

      expect(is_study).to eq Sparc::Protocol.where(id: protocol.sparc_id).first.type == 'Study'
    end
  end
end
