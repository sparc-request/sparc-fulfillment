FactoryGirl.define do

  factory :clinical_provider do
    identity nil
    organization nil

    trait :with_organization do
      organization
    end

    factory :clinical_provider_with_organization, traits: [:with_organization]
  end
end
