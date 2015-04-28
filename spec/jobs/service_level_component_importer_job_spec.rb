require 'rails_helper'

RSpec.describe ServiceLevelComponentImporterJob, type: :job do

  describe '#enqueue', delay: true do

    it 'should create a Delayed::Job' do
      callback_url = "http://#{ENV['SPARC_API_USERNAME']}:#{ENV['SPARC_API_PASSWORD']}@#{ENV['SPARC_API_HOST']}/v1/service_level_components/1.json"

      ServiceLevelComponentImporterJob.enqueue(1, callback_url, 'update')

      expect(Delayed::Job.where(queue: 'sparc_api_requests').count).to eq(1)
    end
  end

  describe '#perform', sparc_api: :get_service_level_component_1 do

    context "#update" do

      before do
        service                               = create(:service, sparc_id: 1)
        @component                            = create(:component_of_service,
                                                        composable_id: service.id,
                                                        sparc_id: 1,
                                                        component: "Test component",
                                                        position: 10)
        callback_url                          = "http://#{ENV['SPARC_API_USERNAME']}:#{ENV['SPARC_API_PASSWORD']}@#{ENV['SPARC_API_HOST']}/v1/service_level_components/1.json?depth=full"
        service_level_component_importer_job  = ServiceLevelComponentImporterJob.new(@component.sparc_id, callback_url, 'update')

        service_level_component_importer_job.perform
      end

      it "should update the local Component" do
        expect(@component.reload.component).to eq("Service Level Component 1")
        expect(@component.reload.position).to eq(1)
      end

      it "should make a request to the objects callback_url" do
        expect(a_request(:get, /\/v1\/service_level_components\/1.json/).
          with( headers: {'Accept' => 'application/json', 'Accept-Encoding' => 'gzip, deflate', 'User-Agent' => 'Ruby'})).to have_been_made.once
      end
    end
  end
end
