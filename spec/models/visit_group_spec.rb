require 'rails_helper'

RSpec.describe VisitGroup, type: :model do

  it { should belong_to(:arm) }

  it { should have_many(:visits) }
end
