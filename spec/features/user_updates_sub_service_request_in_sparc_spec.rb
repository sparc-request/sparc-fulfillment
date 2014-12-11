require 'rails_helper'

RSpec.describe 'User updates SubServiceRequest in SPARC', type: :request, delay: false do

  describe 'full lifecycle' do

    before { user_updates_sub_service_request_in_sparc }

    it 'should create a Protocol with a :sparc_id' do
      protocol = Protocol.first

      expect(protocol.sparc_id).to be
    end
  end

  private

  def user_updates_sub_service_request_in_sparc
    notification  = build(:notification_sub_service_request_update)
    params        = {
      notification: {
        sparc_id: notification.sparc_id,
        kind: notification.kind,
        action: notification.action,
        callback_url: "http://sparc.musc.edu/v1/sub_service_requests/1.json"
      }
    }

    sparc_sends_notification_post params
  end
end
