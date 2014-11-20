require 'rails_helper'

RSpec.describe ProtocolWorkerJob, type: :model do

  describe '#enqueue', delay: true do

    it 'should create a Delayed::Job' do

      ProtocolWorkerJob.enqueue(1, 1)

      expect(Delayed::Job.where(queue: 'sparc_protocol_updater').count).to eq(1)
    end
  end

  describe '#perform', delay: false do

    context 'SPARC API available', sparc_api: :available do

      it 'should make a GET request to SPARC' do
        job = ProtocolWorkerJob.new(1, 1)

        job.perform

        expect(a_request(:get, /#{ENV['SPARC_API_HOST']}/).
          with( query: { sub_service_request_id: '1' },
                headers: {'Accept' => 'application/json'})).to have_been_made.once
      end
    end

    context 'SPARC API unavailable', sparc_api: :unavailable do

      it 'should raise an exception' do
        job = ProtocolWorkerJob.new(1, 1)

        expect{ job.perform }.to raise_exception
      end
    end
  end
end
