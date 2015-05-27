FactoryGirl.define do

  factory :sub_service_request do
    organization nil

    trait :with_organization do
      organization factory: :organization_with_services
    end

    factory :sub_service_request_with_organization, traits: [:with_organization]
  end
end
