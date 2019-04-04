# Copyright © 2011-2019 MUSC Foundation for Research Development~
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

RSpec.describe ProtocolImporterJob, type: :job do

  describe '#enqueue' do

    it 'should create a Active::Job' do
      callback_url = "http://#{ENV['SPARC_API_USERNAME']}:#{ENV['SPARC_API_PASSWORD']}@#{ENV['SPARC_API_HOST']}/v1/sub_service_requests/6213.json"

      ProtocolImporterJob.perform_later(6213, callback_url, 'create')
      
      expect(ProtocolImporterJob).to have_been_enqueued
    end
  end

  describe '#perform', sparc_api: :get_sub_service_request_1, enqueue: false do

    #TODO this needs to be updated to match the current method of import
#    before do
#      service   = create(:service)
#      @identity = create(:identity, email: "email@musc.edu")
#      allow(Service).to receive(:find).and_return(service)
#      allow(Identity).to receive(:find).and_return(@identity)
#
#      callback_url = "http://#{ENV['SPARC_API_USERNAME']}:#{ENV['SPARC_API_PASSWORD']}@#{ENV['SPARC_API_HOST']}/v1/sub_service_requests/6213.json"
#      protocol_job = ProtocolImporterJob.perform_later(6213, callback_url, 'update')
#    end
#
#    it 'should make requests to the objects callback_url' do
#      # SPARC sub_service_request
#      expect(a_request(:get, /\/v1\/sub_service_requests\/6213.json/)).to have_been_made.once
#
#      # SPARC service_request
#      expect(a_request(:get, /\/v1\/service_requests\/201780.json/)).to have_been_made.once
#
#      # SPARC protocol_request
#      expect(a_request(:get, /\/v1\/protocols\/7564.json/)).to have_been_made.once
#    end
#
#    it 'should import the full Protocol' do
#      protocol = Protocol.find_by(sparc_id: 7564)
#
#      # Protocol
#      expect(Protocol.where('sparc_id IS NULL').any?).to_not be
#      expect(protocol.study_cost).to eq(1320300)
#      expect(protocol.status).to eq('Complete')
#
#      # Arms
#      expect(Arm.where('sparc_id IS NULL').any?).to_not be
#      expect(Arm.where('protocol_id IS NULL').any?).to_not be
#      expect(protocol.arms.any?).to be
#      expect(protocol.arms.first.visit_groups.any?).to be
#      expect(protocol.arms.first.visit_groups.first.visits.any?).to be
#
#      # VisitGroups
#      expect(VisitGroup.any?).to be
#      expect(VisitGroup.where('sparc_id IS NULL').any?).to_not be
#      expect(VisitGroup.where('arm_id IS NULL').any?).to_not be
#
#      # LineItems
#      expect(LineItem.any?).to be
#      expect(LineItem.where('arm_id IS NULL').any?).to_not be
#
#      # Visits
#      expect(Visit.any?).to be
#      expect(Visit.where('sparc_id IS NULL').any?).to_not be
#      expect(Visit.where('visit_group_id IS NULL').any?).to_not be
#      expect(Visit.where('line_item_id IS NULL').any?).to_not be
#    end
#
#    it "should POST once to the Faye server on the 'protocols' channel", enqueue: false do
#      expect(a_request(:post, /#{ENV['CWF_FAYE_HOST']}/).with{ |request| request.body.match(/protocols/) }).to have_been_made.once
#    end
#
#    it "should POST once to the Faye server on the 'protocol_id' channel", enqueue: false do
#      protocol = Protocol.find_by(sparc_id: 7564)
#
#      expect(a_request(:post, /#{ENV['CWF_FAYE_HOST']}/).with { |request| request.body.match(/protocol_#{protocol.id}/) }).to have_been_made.once
#    end
#
#    it "should NOT utilize PaperTrail on import", enqueue: false do
#      protocol = Protocol.find_by(sparc_id: 7564)
#
#      expect(protocol.versions.count).to eq(0)
#    end
  end
end
