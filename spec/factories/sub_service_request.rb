FactoryGirl.define do

  factory :sub_service_request do
    organization nil

    trait :with_organization do
      after(:create) do |sub_service_request, evaluator|
        sub_service_request.update_attribute(:organization, Organization.first)
      end
    end

    factory :sub_service_request_with_organization, traits: [:with_organization]
  end
end
