require 'rails_helper'

RSpec.describe RemoteObjectUpdater do

  describe '#import!', delay: true do

    context 'Protocol update' do

      before do
        json            = load_protocol_1_json
        @protocol       = create(:protocol_created_by_sparc)
        object_updater  = RemoteObjectUpdater.new(json, @protocol)

        object_updater.import!
        @protocol.reload
      end

      it 'should update the existing protocol and child objects' do
        expect(@protocol.short_title).to eq('GS-US-321-0106')
        expect(@protocol.arms.count).to eq(1)
        expect(@protocol.arms.first.visit_groups.count).to eq(125)
      end
    end

    context 'Service update' do

      before do
        json            = load_service_1_json
        @service        = create(:service_created_by_sparc)
        object_updater  = RemoteObjectUpdater.new(json, @service)

        object_updater.import!
        @service.reload
      end

      it 'should update the existing service' do
        expect(@service.name).to eq('Biostatistical Education')
      end
    end
  end
end
