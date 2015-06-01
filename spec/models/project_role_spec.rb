require "rails_helper"

RSpec.describe ProjectRole, type: :model do

  it { is_expected.to belong_to(:identity) }
  it { is_expected.to belong_to(:protocol) }
end
