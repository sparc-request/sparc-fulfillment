require 'rails_helper'

RSpec.describe ProtocolUpdaterJob, type: :model do

  describe '#enqueue', delay: true do

    it 'should create a Delayed::Job' do

      ProtocolUpdaterJob.enqueue(1)

      expect(Delayed::Job.where(queue: 'sparc_api_requests').count).to eq(1)
    end
  end

  describe '#perform' do

    context 'SPARC API available', sparc_api: :available do

      it 'should make a GET request to SPARC for Protocol update' do
        create(:protocol_created_by_sparc)

        expect(a_request(:get, /#{ENV['SPARC_API_HOST']}\/v1\/protocols/).
          with( headers: {'Accept' => 'application/json'})).to have_been_made.once
      end
    end

    context 'SPARC API unavailable', sparc_api: :unavailable do

      it 'should raise an exception' do
        job = ProtocolUpdaterJob.new(1)

        expect{ job.perform }.to raise_exception
      end
    end
  end
end
