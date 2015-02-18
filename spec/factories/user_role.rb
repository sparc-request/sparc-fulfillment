FactoryGirl.define do

  factory :user_role do
    user nil
    protocol nil

    trait :pi do
      role "primary-pi"
      user
    end

    trait :coordinator do
      role "research-assistant-coordinator"
      user
    end

    factory :user_role_pi, traits:[:pi]
    factory :user_role_coordinator, traits:[:coordinator]
  end
end
