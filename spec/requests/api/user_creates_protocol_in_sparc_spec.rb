require 'rails_helper'

RSpec.describe 'User creates Protocol in SPARC', type: :request, enqueue: false do

  describe 'full lifecycle' do

    it 'should create and update a Protocol', sparc_api: :get_protocol_1 do
      user_creates_protocol_in_sparc

      expect(Protocol.count).to eq(1)
    end
  end

  private

  def user_creates_protocol_in_sparc
    notification  = build(:notification_protocol_create)
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
