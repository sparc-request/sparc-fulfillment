FactoryGirl.define do

  factory :service, aliases: [:service_created_by_sparc] do
    organization factory: :organization_core
    sequence(:name) { Faker::Commerce.product_name }
    # sparc_organization_name { ['Nexus', 'RCM', 'Something', 'Or Other', 'Wooo'][sparc_organization_id] }
    # sequence(:cost)
    description 'Description'
    abbreviation 'Abbreviation'

    after(:create) do |service|
      pricing_map = build(:pricing_map_past)
      service.pricing_maps << pricing_map
    end

    trait :with_components do
      after(:create) do |service, evaluator|
        create_list(:component_of_service, 3, composable_id: service.id)
      end
    end

    factory :service_with_components, traits: [:with_components]
    factory :service_without_pricing_maps, traits: [:without_pricing_maps]
  end
end
