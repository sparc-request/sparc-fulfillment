require "rails_helper"

RSpec.describe IdentityRole, type: :model do

  it { is_expected.to belong_to(:identity) }
  it { is_expected.to belong_to(:protocol) }

  it { is_expected.to validate_presence_of(:rights) }
  it { is_expected.to validate_presence_of(:role) }
end
