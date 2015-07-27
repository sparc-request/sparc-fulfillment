FactoryGirl.define do

  factory :line_item do
    arm nil
    service nil
    protocol nil
    name nil
    sparc_id
    quantity_requested { Faker::Number.number(3) }
    quantity_type "Each"

    trait :with_fulfillments do
      after(:create) do |line_item, evaluator|
        service = line_item.service
        create(:fulfillment, line_item: line_item, service_id: service.id, service_name: service.name, service_cost: service.cost(line_item.protocol.funding_source))
      end
    end

    factory :line_item_with_fulfillments, traits: [:with_fulfillments]
  end
end
