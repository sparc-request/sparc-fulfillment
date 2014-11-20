require 'rails_helper'

RSpec.describe Protocol, type: :model do

  it { should have_many(:arms) }
end
