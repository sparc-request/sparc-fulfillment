require 'rails_helper'

RSpec.describe SubServiceRequestUpdaterJob do

  describe '#enqueue', delay: true do

    it 'should create a Delayed::Job' do
      callback_url = "http://#{ENV['SPARC_API_USERNAME']}:#{ENV['SPARC_API_PASSWORD']}@#{ENV['SPARC_API_HOST']}/v1/sub_service_requests/6213.json"

      SubServiceRequestUpdaterJob.enqueue(6213, callback_url)

      expect(Delayed::Job.where(queue: 'sparc_api_requests').count).to eq(1)
    end
  end

  describe '#perform', sparc_api: :get_sub_service_request_1 do

    before do
      @protocol = create(:protocol_created_by_sparc, sparc_id: 7564)

      callback_url            = "http://#{ENV['SPARC_API_USERNAME']}:#{ENV['SPARC_API_PASSWORD']}@#{ENV['SPARC_API_HOST']}/v1/sub_service_requests/6213.json"
      sub_service_updater_job = SubServiceRequestUpdaterJob.new(6213, callback_url)

      sub_service_updater_job.perform
    end

    it 'should make requests to the objects callback_url' do
      # SPARC sub_service_request
      expect(a_request(:get, /\/v1\/sub_service_requests\/6213.json/).
        with( headers: {'Accept' => 'application/json', 'Accept-Encoding' => 'gzip, deflate', 'User-Agent' => 'Ruby'})).to have_been_made.once

      # SPARC service_request
      expect(a_request(:get, /\/v1\/service_requests\/201780.json/).
        with( headers: {'Accept' => 'application/json', 'Accept-Encoding' => 'gzip, deflate', 'User-Agent' => 'Ruby'})).to have_been_made.once

      # SPARC protocol_request
      expect(a_request(:get, /\/v1\/protocols\/7564.json/).
        with( headers: {'Accept' => 'application/json', 'Accept-Encoding' => 'gzip, deflate', 'User-Agent' => 'Ruby'})).to have_been_made.once
    end

    it 'should update the local Protocol' do
      expect(@protocol.reload.short_title).to eq('101720')
    end
  end
end
