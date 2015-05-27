require 'rails_helper'

RSpec.describe Report, type: :model do

  it { is_expected.to belong_to(:identity) }

  it { is_expected.to have_one(:document) }
end
