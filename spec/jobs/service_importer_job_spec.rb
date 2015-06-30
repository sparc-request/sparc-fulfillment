require 'rails_helper'

RSpec.describe ServiceImporterJob, type: :job do

  describe '#enqueue', delay: true do

    it 'should create a Delayed::Job' do
      callback_url = "http://#{ENV['SPARC_API_USERNAME']}:#{ENV['SPARC_API_PASSWORD']}@#{ENV['SPARC_API_HOST']}/v1/services/1.json"

      ServiceImporterJob.enqueue(1, callback_url, 'update')

      expect(Delayed::Job.where(queue: 'sparc_api_requests').count).to eq(1)
    end
  end

  describe '#perform', sparc_api: :get_service_components_1 do

    it 'should update line_items components if serviceComponents are changed' do
      line_item = create(:line_item, service: create(:service_with_one_time_fee), protocol: create(:protocol), quantity_requested: 500, quantity_type: 'each')

      callback_url = "http://#{ENV['SPARC_API_USERNAME']}:#{ENV['SPARC_API_PASSWORD']}@#{ENV['SPARC_API_HOST']}/v1/services/1.json"
      ServiceImporterJob.new(1, callback_url, 'update').perform

      expect(line_item.components.map(&:component)).to eq ['a','b','c','o']
    end
  end
end
