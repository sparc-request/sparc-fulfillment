FactoryGirl.define do

  factory :project_role do
    identity nil
    protocol nil
    project_rights "to party"

    trait :pi do
      role "primary-pi"
      identity
    end

    trait :coordinator do
      role "research-assistant-coordinator"
      identity
    end

    factory :project_role_pi, traits:[:pi]
    factory :project_role_coordinator, traits:[:coordinator]
  end
end
