require 'rails_helper'

RSpec.describe RemoteObjectUpdaterJob, type: :job do

  describe '#enqueue', delay: true do

    it 'should create a Delayed::Job' do
      callback_url = "http://#{ENV.fetch('SPARC_API_USERNAME')}:#{ENV.fetch('SPARC_API_PASSWORD')}@#{ENV.fetch('SPARC_API_HOST')}/v1/sub_service_requests/6213.json"

      RemoteObjectUpdaterJob.enqueue(6213, 'protocol', callback_url)

      expect(Delayed::Job.where(queue: 'sparc_api_requests').count).to eq(1)
    end
  end

  describe '#perform' do

    context 'Protocol update', sparc_api: :get_protocol_1 do

      before do
        Protocol.skip_callback :save, :after, :update_faye
        @protocol                 = create( :protocol,
                                            sparc_id: 1,
                                            short_title: 'Short Title')
        callback_url              = "http://#{ENV.fetch('SPARC_API_HOST')}/v1/protocols/1.json"
        remote_object_updater_job = RemoteObjectUpdaterJob.new(@protocol.id, 'protocol', callback_url)

        remote_object_updater_job.perform
      end

      it 'should update the existing protocol' do
        expect(@protocol.reload.short_title).to eq('GS-US-321-0106')
      end

      it 'should not POST to the Faye server' do
        expect(a_request(:post, /#{ENV['CWF_FAYE_HOST']}/)).to_not have_been_made
      end
    end

    context 'Service update', sparc_api: :get_service_1 do

      before do
        @service                  = create( :service_created_by_sparc,
                                            sparc_id: 1,
                                            name: 'Service Name')
        callback_url              = "http://#{ENV.fetch('SPARC_API_HOST')}/v1/services/1.json"
        remote_object_updater_job = RemoteObjectUpdaterJob.new(@service.id, 'service', callback_url)

        remote_object_updater_job.perform
      end

      it 'should update the existing service' do
        expect(@service.reload.name).to eq("Biostatistical Education")
      end
    end
  end
end
