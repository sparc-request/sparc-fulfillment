require "rails_helper"

RSpec.describe HumanSubjectsInfo, type: :model do

  it { is_expected.to belong_to(:protocol) }
end
