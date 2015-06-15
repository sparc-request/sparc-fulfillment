FactoryGirl.define do

  factory :organization do
    sequence(:name) { |n| "Organization #{n}" }
    process_ssrs false

    trait :core do
      type "Core"
    end

    trait :with_protocols do
      after(:create) do |organization, evaluator|
        create(:sub_service_request, organization: organization)
      end
    end

    trait :with_services do
      after(:create) do |organization, evaluator|
        create_list(:service, 3, organization: organization)
        create_list(:service_with_one_time_fee_with_components, 3, organization: organization)
      end
    end

    trait :with_child_organizations do
      after(:create) do |organization, evaluator|
        3.times do
          child = create(:organization_with_services, parent: organization)

          create_list(:organization_with_services, 3, parent: child)
        end
      end
    end

    factory :organization_core, traits: [:core]
    factory :organization_with_protocols, traits: [:core, :with_protocols]
    factory :organization_with_services, traits: [:core, :with_services]
    factory :organization_with_child_organizations, traits: [:with_services, :core, :with_child_organizations]
  end
end
