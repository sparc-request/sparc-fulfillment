require 'rails_helper'

RSpec.describe Protocol, type: :model do

  describe '.sparc_uri' do

    let(:protocol) { create(:protocol) }

    it 'should return a valid URI' do
      expect(protocol.sparc_uri).to eq('http://localhost:5000/portal/admin/sub_service_requests/1')
    end
  end
end
