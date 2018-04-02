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
      protocol.sub_service_request.update_attributes(service_request_id: service_request.id, service_requester_id: identity.id)
      requester = protocol.service_requester.full_name
      expect(helper.formatted_requester(protocol)).to eq(requester)
    end
  end

  describe "#effective_study_cost" do
    it "should return the direct cost as the total if indirect cost is not used" do
      stub_const('ENV', {'USE_INDIRECT_COST' => 'false'})
      protocol = create(:protocol_imported_from_sparc)
      protocol.sparc_protocol.update_attributes(indirect_cost_rate: 25.00)
      sr = create(:service_request, protocol: protocol, status: 'draft')
      ssr = create(:sub_service_request, service_request: sr)
      allow(helper).to receive(:effective_current_total).and_return(100)
      expect(helper.effective_study_cost(protocol)).to eq(100)
    end

    it "should return the direct plus indirect cost as the total if indirect cost is used" do
      stub_const('ENV', {'USE_INDIRECT_COST' => 'true'})
      protocol = create(:protocol_imported_from_sparc)
      protocol.sparc_protocol.update_attributes(indirect_cost_rate: 25.00)
      sr = create(:service_request, protocol: protocol, status: 'draft')
      ssr = create(:sub_service_request, service_request: sr)
      allow(helper).to receive(:effective_current_total).and_return(100)
      expect(helper.effective_study_cost(protocol)).to eq(125)
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
