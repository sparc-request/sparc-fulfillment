require 'rails_helper'

RSpec.describe Notification, type: :model do

  it { is_expected.to validate_presence_of(:sparc_id) }
  it { is_expected.to validate_presence_of(:kind) }
  it { is_expected.to validate_presence_of(:action) }
  it { is_expected.to validate_presence_of(:callback_url) }


  describe 'custom validations' do

    describe '.duplicate_not_present?' do

      context 'duplicate present' do

        it 'should not allow the object to be persisted' do
          create(:notification_sub_service_request_create)
          notification_attributes = attributes_for(:notification_sub_service_request_create)

          expect(Notification.create(notification_attributes)).to have(1).error
        end
      end

      context 'duplicate not present' do

        it 'should allow the object to be persisted' do
          notification = create(:notification_sub_service_request_create)

          expect(notification).to be_persisted
        end
      end
    end
  end
end
