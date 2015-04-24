require 'rails_helper'

RSpec.describe Fulfillment, type: :model do

  it { is_expected.to belong_to(:line_item) }

  it { is_expected.to have_many(:components) }
  it { is_expected.to have_many(:notes) }
  it { is_expected.to have_many(:documents) }

end 