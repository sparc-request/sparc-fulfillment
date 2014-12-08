require 'rails_helper'

RSpec.describe RemoteObjectUpdaterJob, type: :model do

  describe '#enqueue', delay: true do

    it 'should create a Delayed::Job' do

      protocol = create(:protocol_created_by_sparc)

      RemoteObjectUpdaterJob.enqueue(protocol.id, 'Protocol', protocol_callback_url)

      expect(Delayed::Job.where(queue: 'sparc_api_requests').count).to eq(1)
    end
  end

  describe '#perform', delay: false do

    context 'SPARC API available' do

      context 'Protocol', sparc_api: :get_protocol_1 do

        it 'should make a GET request to SPARC for a Protocol' do
          object                    = create(:protocol_created_by_sparc)
          remote_object_updater_job = RemoteObjectUpdaterJob.new(object.id, 'Protocol', protocol_callback_url)

          remote_object_updater_job.perform

          expect(a_request(:get, /#{ENV['SPARC_API_HOST']}\/v1\/protocols\/#{object.sparc_id}.json/).
            with( headers: {'Accept' => 'application/json'})).to have_been_made.once
        end
      end

      context 'Service', sparc_api: :get_service_1 do

        it 'should make a GET request to SPARC for a Service' do
          object                    = create(:service_created_by_sparc)
          remote_object_updater_job = RemoteObjectUpdaterJob.new(object.id, 'Service', service_callback_url)

          remote_object_updater_job.perform

          expect(a_request(:get, /#{ENV['SPARC_API_HOST']}\/v1\/services\/#{object.sparc_id}.json/).
            with( headers: {'Accept' => 'application/json'})).to have_been_made.once
        end
      end
    end

    context 'SPARC API unavailable', sparc_api: :unavailable do

      it 'should raise an exception' do
        protocol      = create(:protocol_created_by_sparc)
        job           = RemoteObjectUpdaterJob.new(protocol.id, 'Protocol', protocol_callback_url)

        expect{ job.perform }.to raise_exception
      end
    end
  end

  private

  def service_callback_url
    "http://sparc.musc.edu/v1/services/1.json"
  end

  def protocol_callback_url
    "http://sparc.musc.edu/v1/protocols/1.json"
  end
end
