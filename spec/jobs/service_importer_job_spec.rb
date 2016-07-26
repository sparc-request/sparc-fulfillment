require 'rails_helper'

RSpec.describe ServiceImporterJob, type: :job do

  describe '#enqueue' do

    it 'should create a Active::Job' do
      callback_url = "http://#{ENV['SPARC_API_USERNAME']}:#{ENV['SPARC_API_PASSWORD']}@#{ENV['SPARC_API_HOST']}/v1/services/1.json"

      ServiceImporterJob.perform_later(1, callback_url, 'update')

      expect(ServiceImporterJob).to have_been_enqueued
    end
  end

  describe '#perform', sparc_api: :get_service_components_1, enqueue: false do

    it 'should update line_items components if serviceComponents are changed' do
      line_item = create(:line_item, service: create(:service_with_one_time_fee), protocol: create(:protocol), quantity_requested: 500, quantity_type: 'each')

      callback_url = "http://#{ENV['SPARC_API_USERNAME']}:#{ENV['SPARC_API_PASSWORD']}@#{ENV['SPARC_API_HOST']}/v1/services/1.json"
      ServiceImporterJob.perform_later(1, callback_url, 'update')

      expect(line_item.components.map(&:component)).to eq ['a','b','c','o']
    end
  end
end
