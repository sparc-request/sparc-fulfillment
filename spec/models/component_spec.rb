require 'rails_helper'

RSpec.describe Component, type: :model do

  it { is_expected.to belong_to(:composable) }

end 