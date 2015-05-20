FactoryGirl.define do

  factory :organization do
    sequence(:name) { |n| "Organization #{n}" }

    trait :core do
      type "Core"
    end

    factory :organization_core, traits: [:core]
  end
end
