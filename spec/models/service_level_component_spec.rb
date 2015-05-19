require "rails_helper"

RSpec.describe ServiceLevelComponent, type: :model do

  it { is_expected.to belong_to(:service) }
end
