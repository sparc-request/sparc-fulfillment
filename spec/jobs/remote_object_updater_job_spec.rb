require 'rails_helper'

RSpec.describe RemoteObjectUpdaterJob, type: :model do

  describe '#enqueue', delay: true do

    before { Protocol.skip_callback(:create, :after, :update_from_sparc) }

    after { Protocol.set_callback(:create, :after, :update_from_sparc) }

    it 'should create a Delayed::Job' do

      protocol = create(:protocol_created_by_sparc)

      RemoteObjectUpdaterJob.enqueue(protocol.id, 'Protocol')

      expect(Delayed::Job.where(queue: 'sparc_api_requests').count).to eq(1)
    end
  end

  describe '#perform', delay: false do

    context 'SPARC API available' do

      context 'Protocol', sparc_api: :get_protocol_1 do

        it 'should make a GET request to SPARC for a Protocol' do
          protocol = create(:protocol_created_by_sparc)

          expect(a_request(:get, /#{ENV['SPARC_API_HOST']}\/v1\/protocols\/#{protocol.sparc_id}.json/).
            with( headers: {'Accept' => 'application/json'})).to have_been_made.once
        end
      end

      context 'Service', sparc_api: :get_service_1 do

        it 'should make a GET request to SPARC for a Service' do
          service = create(:service_created_by_sparc)

          expect(a_request(:get, /#{ENV['SPARC_API_HOST']}\/v1\/services\/#{service.sparc_id}.json/).
            with( headers: {'Accept' => 'application/json'})).to have_been_made.once
        end
      end
    end

    context 'SPARC API unavailable', sparc_api: :unavailable do

      before { Protocol.skip_callback(:create, :after, :update_from_sparc) }

      after { Protocol.set_callback(:create, :after, :update_from_sparc) }

      it 'should raise an exception' do
        protocol  = create(:protocol_created_by_sparc)
        job       = RemoteObjectUpdaterJob.new(protocol.id, 'Protocol')

        expect{ job.perform }.to raise_exception
      end
    end
  end
end
