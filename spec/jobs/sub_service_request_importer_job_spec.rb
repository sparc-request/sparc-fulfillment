require 'rails_helper'

RSpec.describe SubServiceRequestImporterJob, type: :job do

  describe '#enqueue', delay: true do

    it 'should create a Delayed::Job' do
      callback_url = "http://#{ENV['SPARC_API_USERNAME']}:#{ENV['SPARC_API_PASSWORD']}@#{ENV['SPARC_API_HOST']}/v1/sub_service_requests/6213.json"

      SubServiceRequestImporterJob.enqueue(6213, callback_url, 'create')

      expect(Delayed::Job.where(queue: 'sparc_api_requests').count).to eq(1)
    end
  end

  describe '#perform' do

    before do
      callback_url            = "http://#{ENV['SPARC_API_USERNAME']}:#{ENV['SPARC_API_PASSWORD']}@#{ENV['SPARC_API_HOST']}/v1/sub_service_requests/6213.json"
      sub_service_updater_job = SubServiceRequestImporterJob.new(6213, callback_url, 'update')

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

    it 'should import the full Protocol' do
      expect(Protocol.count).to eq(1)
      expect(Protocol.where('sparc_id IS NULL').any?).to_not be
      expect(Protocol.first.arms.any?).to be
      expect(Protocol.first.arms.first.visit_groups.any?).to be
      expect(Protocol.first.arms.first.visit_groups.first.visits.any?).to be

      expect(Arm.any?).to be
      expect(Arm.where('sparc_id IS NULL').any?).to_not be
      expect(Arm.where('protocol_id IS NULL').any?).to_not be

      expect(VisitGroup.any?).to be
      expect(VisitGroup.where('sparc_id IS NULL').any?).to_not be
      expect(VisitGroup.where('arm_id IS NULL').any?).to_not be

      expect(LineItem.any?).to be
      # expect(LineItem.where('service_id IS NULL').any?).to_not be
      expect(LineItem.where('arm_id IS NULL').any?).to_not be

      expect(Visit.any?).to be
      expect(Visit.where('sparc_id IS NULL').any?).to_not be
      expect(Visit.where('visit_group_id IS NULL').any?).to_not be
      expect(Visit.where('line_item_id IS NULL').any?).to_not be
    end

    it "should POST once to the Faye server on the 'protocols' channel", delay: false do
      expect(a_request(:post, /#{ENV['CWF_FAYE_HOST']}/).with{ |request| request.body.match(/protocols/) }).to have_been_made.once
    end

    it "should POST once to the Faye server on the 'protocol_id' channel", delay: false do
      protocol = Protocol.first

      expect(a_request(:post, /#{ENV['CWF_FAYE_HOST']}/).with { |request| request.body.match(/protocol_#{protocol.id}/) }).to have_been_made.once
    end
  end
end
