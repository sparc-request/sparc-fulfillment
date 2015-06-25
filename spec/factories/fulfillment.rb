FactoryGirl.define do

  factory :fulfillment do
    line_item nil
    fulfilled_at "09-09-2025"
    quantity     5
    performer_id 1
  end
end
