require 'rails_helper'

RSpec.describe Visit, type: :model do

  it { should belong_to(:line_item) }
  it { should belong_to(:visit_group) }
end
