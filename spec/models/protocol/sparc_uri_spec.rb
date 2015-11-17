require 'rails_helper'

RSpec.describe Protocol, type: :model do

  describe '.sparc_uri' do

    let(:protocol)            { create :protocol_with_sub_service_request }
    let(:sub_service_request) { protocol.sub_service_request }

    it 'should return a valid URI' do
      expect(protocol.sparc_uri).to eq("http://localhost:5000/portal/admin/sub_service_requests/#{sub_service_request.id}")
    end
  end
end
