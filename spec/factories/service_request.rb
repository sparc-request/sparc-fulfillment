FactoryGirl.define do

  factory :service_request do
    protocol nil

    trait :with_protocol do
      protocol factory: :protocol_imported_from_sparc
    end

    factory :service_request_with_protocol, traits: [:with_protocol]
  end
end
