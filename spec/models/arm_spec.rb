require 'rails_helper'

RSpec.describe Arm, type: :model do

  it { should belong_to(:protocol) }

  it { should have_many(:line_items) }
  it { should have_many(:visit_groups) }
end
