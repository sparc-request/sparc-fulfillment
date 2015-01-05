require 'rails_helper'

RSpec.describe RemoteObjectUpdaterJob do

  describe '#enqueue', delay: true do

    it 'should create a Delayed::Job' do
      callback_url = "http://#{ENV.fetch('SPARC_API_USERNAME')}:#{ENV.fetch('SPARC_API_PASSWORD')}@#{ENV.fetch('SPARC_API_HOST')}/v1/sub_service_requests/6213.json"

      RemoteObjectUpdaterJob.enqueue(6213, 'protocol', callback_url)

      expect(Delayed::Job.where(queue: 'sparc_api_requests').count).to eq(1)
    end
  end

  describe '#perform', vcr: true do

    context 'Protocol update', vcr: :localhost do

      before do
        @protocol                 = create( :protocol_created_by_sparc,
                                            sparc_id: 6213,
                                            short_title: 'Short Title')
        callback_url              = "http://#{ENV.fetch('SPARC_API_HOST')}/v1/protocols/6213.json"
        remote_object_updater_job = RemoteObjectUpdaterJob.new(@protocol.id, 'protocol', callback_url)

        remote_object_updater_job.perform
      end

      it 'should update the existing protocol' do
        expect(@protocol.reload.short_title).to eq('GS-US-321-0106')
      end
    end

    context 'Service update', vcr: :localhost do

      before do
        @service                  = create( :service_created_by_sparc,
                                            sparc_id: 3545,
                                            name: 'Service Name')
        callback_url              = "http://#{ENV.fetch('SPARC_API_HOST')}/v1/services/3545.json"
        remote_object_updater_job = RemoteObjectUpdaterJob.new(@service.id, 'service', callback_url)

        remote_object_updater_job.perform
      end

      it 'should update the existing service' do
        expect(@service.reload.name).to eq("DOPPLER ECHO CONT WAVE; F U-LTD - TECH")
      end
    end
  end
end
