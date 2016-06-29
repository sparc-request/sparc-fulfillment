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

      it 'should not POST to the Faye server' do
        expect(a_request(:post, /#{ENV['CWF_FAYE_HOST']}/)).to_not have_been_made
      end
    end
  end
end
