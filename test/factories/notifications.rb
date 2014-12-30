FactoryGirl.define do

  factory :notification, aliases: [:notification_protocol_create] do
    sparc_id 1
    kind 'Protocol'
    action 'create'
    callback_url 'http://localhost:5000/protocols/1.json'

    trait :protocol do
      kind 'Protocol'
      callback_url 'http://localhost:5000/protocols/1.json'
    end

    trait :service do
      kind 'Service'
      callback_url 'http://localhost:5000/services/1.json'
    end

    trait :sub_service_request do
      kind 'SubServiceRequest'
      callback_url 'http://localhost:5000/sub_service_requests/1.json'
    end

    trait :create do
      action 'create'
    end

    trait :update do
      action 'update'
    end

    factory :notification_service_create, traits: [:service, :create]
    factory :notification_service_update, traits: [:service, :update]
    factory :notification_protocol_update, traits: [:protocol, :update]
    factory :notification_sub_service_request_create, traits: [:sub_service_request, :create]
    factory :notification_sub_service_request_update, traits: [:sub_service_request, :update]
  end
end
