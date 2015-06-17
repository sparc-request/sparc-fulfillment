require 'rails_helper'

RSpec.describe Document, type: :model do
  it { is_expected.to belong_to(:documentable) }
end
