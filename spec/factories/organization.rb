FactoryGirl.define do

  factory :organization do
    sequence(:name) { |n| "Fake Organization #{n}" }  # need this for fake data
    process_ssrs false

    after :create do |organization, evaluator|
      create_list(:pricing_setup, 3, organization: organization).each do |pricing_setup|
        pricing_setup.update_attributes(organization_id: organization.id)
      end
    end

    trait :core do
      type "Core"
    end

    trait :program do
      type "Program"
    end

    trait :provider do
      type "Provider"
    end

    trait :with_protocols do
      after(:create) do |organization, evaluator|
        create(:sub_service_request, organization: organization)
      end
    end

    trait :with_services do
      after(:create) do |organization, evaluator|
        create_list(:service, 4, organization: organization)
        create_list(:service_with_one_time_fee, 4, organization: organization)
      end
    end

    trait :with_child_organizations do
      after(:create) do |organization, evaluator|
        3.times do
          child = create(:organization_with_services, parent: organization)

          create_list(:organization_with_services, 3, parent: child)
        end
      end
    end

    factory :organization_core, traits: [:core]
    factory :organization_program, traits: [:program]
    factory :organization_provider, traits: [:provider]
    factory :organization_with_protocols, traits: [:core, :with_protocols]
    factory :organization_with_services, traits: [:core, :with_services]
    factory :organization_with_child_organizations, traits: [:with_services, :core, :with_child_organizations]
  end
end
