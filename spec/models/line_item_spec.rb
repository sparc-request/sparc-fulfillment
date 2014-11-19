require 'rails_helper'

RSpec.describe LineItem, type: :model do

  it { should belong_to(:arm) }
  it { should belong_to(:service) }

  it { should have_many(:visits) }
end
