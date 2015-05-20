require 'rails_helper'

RSpec.describe Report, type: :model do
  it { should belong_to(:user) }
  it { is_expected.to have_one(:document) }
end
