require 'rails_helper'

RSpec.describe 'User creates Service in SPARC', type: :request, delay: false do

  describe 'full lifecycle' do

    it 'should create and update a Service', sparc_api: :get_service_1 do
      user_creates_service_in_sparc

      expect(Service.count).to eq(1)
    end
  end

  private

  def user_creates_service_in_sparc
    notification  = build(:notification_service_create)
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
