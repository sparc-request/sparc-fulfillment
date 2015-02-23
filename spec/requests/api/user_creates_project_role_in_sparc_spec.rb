require 'rails_helper'

RSpec.describe 'User creates ProjectRole in SPARC', type: :request, delay: false do

  describe 'full lifecycle' do

    context 'User does not exist in CWF' do

      it 'should create a User', sparc_api: :get_project_role_1 do
        user_creates_project_role_in_sparc

        expect(User.count).to eq(1)
      end
    end
  end

  private

  def user_creates_project_role_in_sparc
    notification  = build(:notification_project_role_create)
    params        = {
      notification: {
        sparc_id: notification.sparc_id,
        kind: notification.kind,
        action: notification.action,
        callback_url: notification.callback_url
      }
    }

    sparc_sends_notification_post params
  end
end
