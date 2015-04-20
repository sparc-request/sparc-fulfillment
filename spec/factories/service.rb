FactoryGirl.define do

  factory :service, aliases: [:service_created_by_sparc] do
    sparc_id
    sequence(:name) { Faker::Commerce.product_name }
    sparc_core_id { rand(0..4) }
    sparc_core_name { ['Nexus', 'RCM', 'Something', 'Or Other', 'Wooo'][sparc_core_id] }
    sequence(:cost)
    description 'Description'
    abbreviation 'Abbreviation'

    trait :with_components do
      after(:create) do |service, evaluator|
        create_list(:component_of_service, 3, composable_id: service.id)
      end
    end

    factory :service_with_components, traits: [:with_components]
  end
end
