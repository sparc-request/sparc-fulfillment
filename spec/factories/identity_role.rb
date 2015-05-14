FactoryGirl.define do

  factory :identity_role do
    identity nil
    protocol nil

    trait :pi do
      role "primary-pi"
      identity
    end

    trait :coordinator do
      role "research-assistant-coordinator"
      identity
    end

    factory :identity_role_pi, traits:[:pi]
    factory :identity_role_coordinator, traits:[:coordinator]
  end
end
