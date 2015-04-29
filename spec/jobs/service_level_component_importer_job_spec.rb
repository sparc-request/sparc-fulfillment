require 'rails_helper'

RSpec.describe ServiceLevelComponentImporterJob, type: :job do

  describe '#enqueue', delay: true do

    it 'should create a Delayed::Job' do
      callback_url = "http://#{ENV['SPARC_API_USERNAME']}:#{ENV['SPARC_API_PASSWORD']}@#{ENV['SPARC_API_HOST']}/v1/service_level_components/1.json"

      ServiceLevelComponentImporterJob.enqueue(1, callback_url, 'update')

      expect(Delayed::Job.where(queue: 'sparc_api_requests').count).to eq(1)
    end
  end

  describe "#perform" do

    context "#create", vcr: true do

      before do
        @service        = create(:service_with_components, sparc_id: 3547)
        @component_ids  = @service.components.pluck(:id)

        callback_url                          = "http://#{ENV['SPARC_API_USERNAME']}:#{ENV['SPARC_API_PASSWORD']}@#{ENV['SPARC_API_HOST']}/v1/service_level_components/7.json?depth=full"
        service_level_component_importer_job  = ServiceLevelComponentImporterJob.new(7, callback_url, 'create')

        service_level_component_importer_job.perform
      end

      it "should destroy all Components associated with the Service" do
        expect(@service.components.where(id: @component_ids).count).to eq(0)
      end

      it "should create new Components associated with the Service" do
        expect(@service.components.count).to eq(1)
      end
    end

    context "#update", vcr: true do

      before do
        @service        = create(:service_with_components, sparc_id: 3547)
        @component_ids  = @service.components.pluck(:id)

        callback_url                          = "http://#{ENV['SPARC_API_USERNAME']}:#{ENV['SPARC_API_PASSWORD']}@#{ENV['SPARC_API_HOST']}/v1/service_level_components/7.json?depth=full"
        service_level_component_importer_job  = ServiceLevelComponentImporterJob.new(7, callback_url, 'update')

        service_level_component_importer_job.perform
      end

      it "should destroy all Components associated with the Service" do
        expect(@service.components.where(id: @component_ids).count).to eq(0)
      end

      it "should create new Components associated with the Service" do
        expect(@service.components.count).to eq(1)
      end
    end

    context "#destroy", vcr: true do

      before do
        @service        = create(:service_with_components, sparc_id: 3547)
        @component_ids  = @service.components.pluck(:id)

        callback_url                          = "http://#{ENV['SPARC_API_USERNAME']}:#{ENV['SPARC_API_PASSWORD']}@#{ENV['SPARC_API_HOST']}/v1/service_level_components/7.json?depth=full"
        service_level_component_importer_job  = ServiceLevelComponentImporterJob.new(7, callback_url, 'destroy')

        service_level_component_importer_job.perform
      end

      it "should destroy all Components associated with the Service" do
        expect(@service.components.where(id: @component_ids).count).to eq(0)
      end

      it "should create new Components associated with the Service" do
        expect(@service.components.count).to eq(1)
      end
    end
  end
end
