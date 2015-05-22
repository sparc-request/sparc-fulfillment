FactoryGirl.define do

  factory :organization do
    sequence(:name) { |n| "Organization #{n}" }

    trait :core do
      type "Core"
    end

    trait :with_protocols do
      after(:create) do |organization, evaluator|
        create(:sub_service_request, organization: organization)
      end
    end

    factory :organization_core, traits: [:core]
    factory :organization_with_protocols, traits: [:core, :with_protocols]
  end
end
