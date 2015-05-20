require "rails_helper"

RSpec.describe ClinicalProvider, type: :model do

  it { is_expected.to belong_to(:identity) }
  it { is_expected.to belong_to(:organization) }
end
