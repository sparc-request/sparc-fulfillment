require 'rails_helper'

RSpec.describe ServiceImporterJob, type: :job do

  describe '#enqueue', delay: true do

    it 'should create a Delayed::Job' do
      callback_url = "http://#{ENV['SPARC_API_USERNAME']}:#{ENV['SPARC_API_PASSWORD']}@#{ENV['SPARC_API_HOST']}/v1/services/1.json"

      ServiceImporterJob.enqueue(1, callback_url, 'create')

      expect(Delayed::Job.where(queue: 'sparc_api_requests').count).to eq(1)
    end
  end

  describe '#perform', sparc_api: :get_service_1 do

    context "create" do

      before do
        callback_url          = "http://#{ENV['SPARC_API_USERNAME']}:#{ENV['SPARC_API_PASSWORD']}@#{ENV['SPARC_API_HOST']}/v1/services/1.json"
        service_importer_job  = ServiceImporterJob.new(1, callback_url, 'create')

        service_importer_job.perform
      end

      it 'should make requests to the objects callback_url' do
        expect(a_request(:get, /\/v1\/services\/1.json/).
          with( headers: {'Accept' => 'application/json', 'Accept-Encoding' => 'gzip, deflate', 'User-Agent' => 'Ruby'})).to have_been_made.once
      end

      it 'should import the full Service' do
        service = Service.find_by(sparc_id: 1)

        expect(service).to be
      end

      it "should create associated ServiceLevelComponents" do
        service = Service.find_by(sparc_id: 1)

        expect(service.components.count).to eq(3)
      end
    end

    context "#update" do

      before do
        @service              = create(:service_with_components, sparc_id: 1, name: "Test name")
        callback_url          = "http://#{ENV['SPARC_API_USERNAME']}:#{ENV['SPARC_API_PASSWORD']}@#{ENV['SPARC_API_HOST']}/v1/services/1.json"
        service_importer_job  = ServiceImporterJob.new(1, callback_url, 'update')

        service_importer_job.perform
      end

      it "should update the local Service" do
        expect(@service.reload.name).to eq("Biostatistical Education")
      end

      it "should make a request to the objects callback_url" do
        expect(a_request(:get, /\/v1\/services\/1.json/).
          with( headers: {'Accept' => 'application/json', 'Accept-Encoding' => 'gzip, deflate', 'User-Agent' => 'Ruby'})).to have_been_made.once
      end
    end
  end
end
