FactoryGirl.define do

  factory :pricing_map, aliases: [:pricing_map_present] do
    effective_date Time.current
    full_rate 500.0
    quantity_type "Each"

    trait :future do
      effective_date Time.current + 25.days
    end

    trait :past do
      effective_date Time.current - 25.days
    end

    factory :pricing_map_future, traits: [:future]
    factory :pricing_map_past, traits: [:past]
  end
end
