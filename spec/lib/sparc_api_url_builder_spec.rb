require 'rails_helper'

RSpec.describe SparcApiUrlBuilder do

  describe 'resource URL' do

    context 'without params' do

      it 'should return a correctly formatted URL' do
        expected_url = "http://#{ENV.fetch('SPARC_API_USERNAME')}:#{ENV.fetch('SPARC_API_PASSWORD')}@#{ENV.fetch('SPARC_API_HOST')}/#{ENV.fetch('SPARC_API_VERSION')}/services/1.json"

        expect(SparcApiUrlBuilder.new('service', 1).to_s).to eq(expected_url)
      end
    end

    context 'with params' do

      it 'should return a correctly formatted URL' do
        expected_url = "http://#{ENV.fetch('SPARC_API_USERNAME')}:#{ENV.fetch('SPARC_API_PASSWORD')}@#{ENV.fetch('SPARC_API_HOST')}/#{ENV.fetch('SPARC_API_VERSION')}/services/1.json?depth=full_with_shallow_reflections"

        expect(SparcApiUrlBuilder.new('service', 1, { depth: 'full_with_shallow_reflections' }).to_s).to eq(expected_url)
      end
    end
  end

  describe 'resources URL' do

    context 'without params' do

      it 'should return a correctly formatted URL' do
        expected_url = "http://#{ENV.fetch('SPARC_API_USERNAME')}:#{ENV.fetch('SPARC_API_PASSWORD')}@#{ENV.fetch('SPARC_API_HOST')}/#{ENV.fetch('SPARC_API_VERSION')}/services.json"

        expect(SparcApiUrlBuilder.new('service').to_s).to eq(expected_url)
      end
    end

    context 'with params' do

      it 'should return a correctly formatted URL' do
        expected_url = "http://#{ENV.fetch('SPARC_API_USERNAME')}:#{ENV.fetch('SPARC_API_PASSWORD')}@#{ENV.fetch('SPARC_API_HOST')}/#{ENV.fetch('SPARC_API_VERSION')}/services.json?depth=full_with_shallow_reflections"

        expect(SparcApiUrlBuilder.new('service', nil, { depth: 'full_with_shallow_reflections' }).to_s).to eq(expected_url)
      end
    end
  end
end
