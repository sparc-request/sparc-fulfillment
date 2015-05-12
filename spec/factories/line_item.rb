FactoryGirl.define do

  factory :line_item do
    arm nil
    service nil
    protocol nil
    sparc_id
    quantity_requested { Faker::Number.number(3) }
    quantity_type "Each"

    trait :with_fulfillments do
      after(:create) do |line_item, evaluator|
        create(:fulfillment, line_item: line_item)
      end
    end

    factory :line_item_with_fulfillments, traits: [:with_fulfillments]
  end
end
