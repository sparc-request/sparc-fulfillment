require 'rails_helper'

RSpec.describe Notification, type: :model do

  it { should validate_presence_of(:sparc_id) }
  it { should validate_presence_of(:kind) }
  it { should validate_presence_of(:action) }
  it { should validate_presence_of(:callback_url) }
end
