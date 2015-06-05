require "rails_helper"

RSpec.describe Organization, type: :model do

  it { is_expected.to belong_to(:parent) }
  it { is_expected.to have_many(:services) }
  it { is_expected.to have_many(:sub_service_requests) }
end
