require 'rails_helper'

RSpec.describe ServiceRequest, type: :model do

  it { is_expected.to belong_to(:protocol) }
  it { is_expected.to have_many(:sub_service_requests) }
end
