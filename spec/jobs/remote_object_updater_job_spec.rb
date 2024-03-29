# Copyright © 2011-2023 MUSC Foundation for Research Development~
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

RSpec.describe RemoteObjectUpdaterJob, type: :job do

  describe '#perform_later' do

    it 'should enqueue an ActiveJob' do
      expect { create(:notification_protocol_update) }.to enqueue_a(RemoteObjectUpdaterJob)
    end

    context 'Protocol update', sparc_api: :get_protocol_1 do

      before :each do
        @protocol                 = create( :protocol,
                                            sparc_id: 1,
                                            sponsor_name: "protocol",
                                            sub_service_request_id: 1)
        @sibling_protocol         = create( :protocol,
                                            sparc_id: 2,
                                            sponsor_name: "sibling protocol",
                                            sub_service_request_id: 1)
        notification              = create( :notification_protocol_update,
                                            sparc_id: @protocol.sparc_id,
                                            callback_url: "http://#{ENV.fetch('SPARC_API_HOST')}/v1/protocols/1.json")

        RemoteObjectUpdaterJob.perform_now(notification)
      end

      it 'should update the existing protocol' do
        expect(@protocol.reload.sponsor_name).to eq("GILEAD")
      end

      it 'should update Protocol siblings' do
        expect(@sibling_protocol.reload.sponsor_name).to eq("GILEAD")
      end

    end
  end
end
