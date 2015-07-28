require 'rails_helper'

RSpec.describe 'User updates Protocol in SPARC', type: :request, enqueue: false do

  describe 'full lifecycle' do

    it 'should update the Protocol', sparc_api: :get_protocol_1 do
      protocol = create(:protocol, sparc_id: 1, sponsor_name: "Original sponsor name")

      user_updates_protocol_in_sparc

      expect(protocol.reload.sponsor_name).to eq("GILEAD")
    end
  end

  private

  def user_updates_protocol_in_sparc
    notification  = build(:notification_protocol_update, sparc_id: 1)
    params        = {
      notification: {
        sparc_id: notification.sparc_id,
        kind: notification.kind,
        action: notification.action,
        callback_url: "http://localhost:5000/v1/protocols/1.json"
      }
    }

    sparc_sends_notification_post params
  end
end
