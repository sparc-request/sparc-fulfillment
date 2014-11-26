require 'rails_helper'

RSpec.describe ProtocolUpdater, type: :model do

  describe '#import!', delay: true do

    it 'should update the existing protocol' do
      protocol          = create(:protocol_created_by_sparc)
      json              = load_json
      protocol_updater  = ProtocolUpdater.new(json, protocol.id)

      protocol_updater.import!

      expect(protocol.reload.short_title).to eq('GS-US-321-0106')
    end
  end

  private

  def load_json
    file  = ::Rails.root.join('vcr_cassettes', 'reusable', 'sparc_response_to_get_protocol_1.yml')
    yaml  = YAML.load_file file

    yaml["http_interactions"][0]["response"]["body"]["string"]
  end
end
