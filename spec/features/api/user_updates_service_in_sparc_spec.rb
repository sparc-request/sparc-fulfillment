require 'rails_helper'

RSpec.describe 'User updates Service in SPARC', type: :request, delay: false do

  describe 'full lifecycle' do

    it 'should update the Service', sparc_api: :get_service_1 do
      service = create(:service, sparc_id: 1)

      user_updates_service_in_sparc

      expect(service.reload.name).to eq('Biostatistical Education')
    end
  end

  private

  def user_updates_service_in_sparc
    notification  = build(:notification_service_update)
    params        = {
      notification: {
        sparc_id: notification.sparc_id,
        kind: notification.kind,
        action: notification.action,
        callback_url: "http://sparc.musc.edu/v1/services/1.json"
      }
    }

    sparc_sends_notification_post params
  end
end
