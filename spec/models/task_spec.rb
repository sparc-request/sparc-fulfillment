require "rails_helper"

RSpec.describe Task, type: :model do

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:assignee).counter_cache(true) }

  it { is_expected.to validate_presence_of(:due_date) }
  it { is_expected.to validate_presence_of(:assignee_id) }
end
