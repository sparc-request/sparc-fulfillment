require 'rails_helper'

RSpec.describe ProtocolHelper do

  describe "#formatted_status" do
    it "should return the formatted status" do
      protocol = create_and_assign_protocol_to_me
      protocol.sub_service_request.update_attributes(status: "Completed")
      status = t(:sub_service_request)[:statuses][protocol.status.to_sym]
      expect(helper.formatted_status(protocol)).to eq(status)
    end
  end

  describe "#formatted_owner" do
    it "should return the formatted owner" do
      identity = create(:identity)
      protocol = create_and_assign_protocol_to_me
      protocol.sub_service_request.update_attributes(owner_id: identity.id)
      owner = protocol.owner.full_name
      expect(helper.formatted_owner(protocol)).to eq(owner)
    end
  end

  describe "#formatted_requester" do
    it "should return the formatted_requester" do
      identity = create(:identity)
      protocol = create(:protocol_imported_from_sparc)
      service_request = create(:service_request, protocol: protocol)
      protocol.sub_service_request.update_attributes(service_request_id: service_request.id)
      protocol.sub_service_request.service_request.update_attributes(service_requester_id: identity.id)
      requester = protocol.service_requester.full_name
      expect(helper.formatted_requester(protocol)).to eq(requester)
    end
  end

  describe "#arm_per_participant_line_items_by_core" do
    it "should return the line items of arm" do
      arm = create(:protocol_imported_from_sparc).arms.first
      consolidated = true
      hash = helper.arm_per_participant_line_items_by_core(arm, consolidated)

      i = 0
      hash.each do |item|
        if i % 2 == 0
          expect(item.class.name.demodulize == "Core")
        else
          expect(item.class.name.demodulize == "LineItem")
        end
      end
    end
  end

  describe "#consolidated_one_time_fee_line_items" do
    it "should return the line items of the protocol" do
      protocol = create(:protocol_imported_from_sparc)
      expect(helper.consolidated_one_time_fee_line_items(protocol).length == 1)
    end
  end
end
