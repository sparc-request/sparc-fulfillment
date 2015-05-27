require 'rails_helper'

RSpec.describe SubServiceRequest, type: :model do

  it { is_expected.to belong_to(:organization) }
  it { is_expected.to belong_to(:service_request) }
  it { is_expected.to have_one(:protocol) }
end
