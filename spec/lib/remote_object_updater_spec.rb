require 'rails_helper'

RSpec.describe RemoteObjectUpdater, type: :model do

  describe '#import!', delay: true do

    before { @protocol = create(:protocol_created_by_sparc) }

    context 'protocol update' do

      before do
        json            = load_protocol_json
        object_updater  = RemoteObjectUpdater.new(json, @protocol.id)

        object_updater.import!
        @protocol.reload
      end

      it 'should update the existing protocol and child objects' do
        expect(@protocol.short_title).to eq('GS-US-321-0106')
        expect(@protocol.arms.count).to eq(1)
        expect(@protocol.arms.first.visit_groups.count).to eq(125)
      end
    end

    context 'sub_service_request update' do

      before do
        json            = load_sub_service_request_json
        object_updater  = RemoteObjectUpdater.new(json, @protocol.sparc_sub_service_request_id)

        object_updater.import!
        @protocol.reload
      end

      it 'should update the existing protocol and child objects', skip: true do
        expect(@protocol.short_title).to eq('GS-US-321-0106')
        expect(@protocol.arms.count).to eq(1)
        expect(@protocol.arms.first.visit_groups.count).to eq(125)
      end
    end
  end

  private

  def load_protocol_json
    file  = ::Rails.root.join('vcr_cassettes', 'reusable', 'sparc_response_to_get_protocol_1.yml')
    yaml  = YAML.load_file file

    yaml["http_interactions"][0]["response"]["body"]["string"]
  end

  def load_sub_service_request_json
    file  = ::Rails.root.join('vcr_cassettes', 'reusable', 'sparc_response_to_get_sub_service_request_1.yml')
    yaml  = YAML.load_file file

    yaml["http_interactions"][0]["response"]["body"]["string"]
  end
end
