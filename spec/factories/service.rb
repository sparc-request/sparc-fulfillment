FactoryGirl.define do

  factory :service, aliases: [:service_created_by_sparc] do
    organization factory: :organization_core
    sequence(:name) { Faker::Commerce.product_name }
    description 'Description'
    abbreviation 'Abbreviation'
    one_time_fee false

    after(:create) do |service|
      pricing_map = build(:pricing_map_past)
      service.pricing_maps << pricing_map
    end

    after(:create) do |service|
      pricing_map = build(:pricing_map_past)
      service.pricing_maps << pricing_map
    end

    trait :with_components do
      after(:create) do |service, evaluator|
        create_list(:service_level_component, 3, service: service)
      end
    end

    trait :with_one_time_fee do
      one_time_fee true
    end

    factory :service_with_components, traits: [:with_components]
    factory :service_with_one_time_fee, traits: [:with_one_time_fee]
    factory :service_with_one_time_fee_with_components, traits: [:with_one_time_fee, :with_components]
    factory :service_without_pricing_maps, traits: [:without_pricing_maps]
  end
end
