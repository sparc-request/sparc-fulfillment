require 'rails_helper'

RSpec.describe RemoteRequestBuilder do

  describe '#authorize_and_decorate!' do

    it 'should add HTTP basic auth and the default :depth to the url' do
      original_url = "http://#{ENV.fetch('SPARC_API_HOST')}/#{ENV.fetch('SPARC_API_VERSION')}/services/1.json"
      expected_url = "http://#{ENV.fetch('SPARC_API_USERNAME')}:#{ENV.fetch('SPARC_API_PASSWORD')}@#{ENV.fetch('SPARC_API_HOST')}/#{ENV.fetch('SPARC_API_VERSION')}/services/1.json?depth=full"

      expect(RemoteRequestBuilder.authorize_and_decorate!(original_url)).to eq(expected_url)
    end
  end

  describe '#build' do

    context 'single resource' do

      it 'should return a valid URL' do
        expected_url = "http://#{ENV.fetch('SPARC_API_HOST')}/#{ENV.fetch('SPARC_API_VERSION')}/services/1.json"

        expect(RemoteRequestBuilder.new('service', 1).build).to eq(expected_url)
      end
    end

    context 'multiple resources' do

      context 'with params[:ids]' do

        it 'should return a valid URL' do
          expected_url = "http://#{ENV.fetch('SPARC_API_HOST')}/#{ENV.fetch('SPARC_API_VERSION')}/services.json?ids%5B%5D=1&ids%5B%5D=2&ids%5B%5D=3"

          expect(RemoteRequestBuilder.new('service', [1, 2, 3]).build).to eq(expected_url)
        end
      end

      context 'with params[:depth]' do

        it 'should return a valid URL' do
          expected_url = "http://#{ENV.fetch('SPARC_API_HOST')}/#{ENV.fetch('SPARC_API_VERSION')}/services/1.json?depth=full_with_shallow_reflections"

          expect(RemoteRequestBuilder.new('service', 1, { depth: 'full_with_shallow_reflections' }).build).to eq(expected_url)
        end
      end

      context 'with params[:depth] and params[:ids]' do

        it 'should return a valid URL' do
          expected_url = "http://#{ENV.fetch('SPARC_API_HOST')}/#{ENV.fetch('SPARC_API_VERSION')}/services.json?depth=full_with_shallow_reflections&ids%5B%5D=1&ids%5B%5D=2&ids%5B%5D=3"

          expect(RemoteRequestBuilder.new('service', [1, 2, 3], { depth: 'full_with_shallow_reflections' }).build).to eq(expected_url)
        end
      end
    end
  end
end
