require 'rails_helper'

RSpec.describe Notification, type: :model do

  it { should validate_presence_of(:sparc_id) }
  it { should validate_presence_of(:kind) }
  it { should validate_presence_of(:action) }
  it { should validate_presence_of(:callback_url) }

  context 'class methods' do

    describe 'callbacks' do

      it 'should callback :update_via_faye after save' do
        notification = create(:notification)

        expect(notification).to callback(:create_or_update_object).after(:create)
      end
    end
  end
end
