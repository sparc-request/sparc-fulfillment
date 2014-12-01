require 'rails_helper'

RSpec.describe ProtocolUpdater, type: :model do

  describe '#import!', delay: true do

    before do
      @protocol         = create(:protocol_created_by_sparc)
      json              = load_json
      protocol_updater  = ProtocolUpdater.new(json, @protocol.id)

      protocol_updater.import!
      @protocol.reload
    end

    it 'should update the existing protocol' do
      expect(@protocol.short_title).to eq('GS-US-321-0106')
      expect(@protocol.arms.count).to eq(1)
      expect(@protocol.arms.first.visit_groups.count).to eq(125)
    end
  end

  private

  def load_json
    file  = ::Rails.root.join('vcr_cassettes', 'reusable', 'sparc_response_to_get_protocol_1.yml')
    yaml  = YAML.load_file file

    yaml["http_interactions"][0]["response"]["body"]["string"]
  end
end
